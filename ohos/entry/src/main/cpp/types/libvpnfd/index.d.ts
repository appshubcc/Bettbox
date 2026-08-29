export const initServer: () => boolean;
export const closeServer: () => boolean;
export const sendFd: (fd: number) => boolean;
export const receiveFd: () => number;
