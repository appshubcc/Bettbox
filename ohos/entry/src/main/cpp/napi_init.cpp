#define _GNU_SOURCE

#include "napi/native_api.h"

#include <cerrno>
#include <cstddef>
#include <cstring>
#include <fcntl.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

namespace {

constexpr char SOCKET_NAME[] = "bettbox_vpn_fd_v1";
int serverFd = -1;

socklen_t FillSocketAddress(sockaddr_un &address)
{
    std::memset(&address, 0, sizeof(address));
    address.sun_family = AF_UNIX;
    address.sun_path[0] = '\0';
    std::memcpy(address.sun_path + 1, SOCKET_NAME, sizeof(SOCKET_NAME) - 1);
    return static_cast<socklen_t>(offsetof(sockaddr_un, sun_path) + 1 + sizeof(SOCKET_NAME) - 1);
}

void CloseServerSocket()
{
    if (serverFd >= 0) {
        close(serverFd);
        serverFd = -1;
    }
}

napi_value BooleanResult(napi_env env, bool value)
{
    napi_value result;
    napi_get_boolean(env, value, &result);
    return result;
}

napi_value InitServer(napi_env env, napi_callback_info)
{
    if (serverFd >= 0) {
        return BooleanResult(env, true);
    }

    const int fd = socket(AF_UNIX, SOCK_SEQPACKET | SOCK_CLOEXEC, 0);
    if (fd < 0) {
        return BooleanResult(env, false);
    }

    sockaddr_un address;
    const socklen_t addressLength = FillSocketAddress(address);
    if (bind(fd, reinterpret_cast<sockaddr *>(&address), addressLength) != 0 || listen(fd, 1) != 0) {
        close(fd);
        return BooleanResult(env, false);
    }

    serverFd = fd;
    return BooleanResult(env, true);
}

napi_value CloseServer(napi_env env, napi_callback_info)
{
    CloseServerSocket();
    return BooleanResult(env, true);
}

napi_value SendFd(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    if (napi_get_cb_info(env, info, &argc, args, nullptr, nullptr) != napi_ok || argc != 1) {
        return BooleanResult(env, false);
    }

    int32_t tunFd = -1;
    if (napi_get_value_int32(env, args[0], &tunFd) != napi_ok || tunFd < 0) {
        return BooleanResult(env, false);
    }

    const int socketFd = socket(AF_UNIX, SOCK_SEQPACKET | SOCK_CLOEXEC, 0);
    if (socketFd < 0) {
        return BooleanResult(env, false);
    }

    sockaddr_un address;
    const socklen_t addressLength = FillSocketAddress(address);
    if (connect(socketFd, reinterpret_cast<sockaddr *>(&address), addressLength) != 0) {
        close(socketFd);
        return BooleanResult(env, false);
    }

    char payload = 1;
    iovec io = {&payload, sizeof(payload)};
    char control[CMSG_SPACE(sizeof(int))] = {};
    msghdr message = {};
    message.msg_iov = &io;
    message.msg_iovlen = 1;
    message.msg_control = control;
    message.msg_controllen = sizeof(control);

    cmsghdr *header = CMSG_FIRSTHDR(&message);
    header->cmsg_level = SOL_SOCKET;
    header->cmsg_type = SCM_RIGHTS;
    header->cmsg_len = CMSG_LEN(sizeof(int));
    std::memcpy(CMSG_DATA(header), &tunFd, sizeof(tunFd));

    const bool sent = sendmsg(socketFd, &message, MSG_NOSIGNAL) == sizeof(payload);
    close(socketFd);
    return BooleanResult(env, sent);
}

napi_value ReceiveFd(napi_env env, napi_callback_info)
{
    int receivedFd = -1;
    if (serverFd >= 0) {
        const int connectionFd = accept4(serverFd, nullptr, nullptr, SOCK_CLOEXEC);
        if (connectionFd >= 0) {
            ucred credentials = {};
            socklen_t credentialsLength = sizeof(credentials);
            const bool trusted = getsockopt(connectionFd, SOL_SOCKET, SO_PEERCRED, &credentials,
                &credentialsLength) == 0 && credentials.uid == getuid();
            if (trusted) {
                char payload = 0;
                iovec io = {&payload, sizeof(payload)};
                char control[CMSG_SPACE(sizeof(int))] = {};
                msghdr message = {};
                message.msg_iov = &io;
                message.msg_iovlen = 1;
                message.msg_control = control;
                message.msg_controllen = sizeof(control);

                if (recvmsg(connectionFd, &message, 0) == sizeof(payload)) {
                    for (cmsghdr *header = CMSG_FIRSTHDR(&message); header != nullptr;
                         header = CMSG_NXTHDR(&message, header)) {
                        if (header->cmsg_level == SOL_SOCKET && header->cmsg_type == SCM_RIGHTS &&
                            header->cmsg_len >= CMSG_LEN(sizeof(int))) {
                            std::memcpy(&receivedFd, CMSG_DATA(header), sizeof(receivedFd));
                            break;
                        }
                    }
                }
            }
            close(connectionFd);
        }
    }

    napi_value result;
    napi_create_int32(env, receivedFd, &result);
    return result;
}

napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor properties[] = {
        {"initServer", nullptr, InitServer, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"closeServer", nullptr, CloseServer, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"sendFd", nullptr, SendFd, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"receiveFd", nullptr, ReceiveFd, nullptr, nullptr, nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(properties) / sizeof(properties[0]), properties);
    return exports;
}

} // namespace

static napi_module vpnFdModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "vpnfd",
    .nm_priv = nullptr,
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterVpnFdModule()
{
    napi_module_register(&vpnFdModule);
}
