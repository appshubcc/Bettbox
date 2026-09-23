package com.appshub.bettbox

import android.database.Cursor
import android.database.MatrixCursor
import android.os.CancellationSignal
import android.os.ParcelFileDescriptor
import android.provider.DocumentsContract.Document
import android.provider.DocumentsContract.Root
import android.provider.DocumentsProvider
import java.io.File
import java.io.FileNotFoundException

class FilesProvider : DocumentsProvider() {

    companion object {
        private const val DEFAULT_ROOT_ID = "0"

        private val DEFAULT_DOCUMENT_COLUMNS = arrayOf(
            Document.COLUMN_DOCUMENT_ID,
            Document.COLUMN_DISPLAY_NAME,
            Document.COLUMN_MIME_TYPE,
            Document.COLUMN_FLAGS,
            Document.COLUMN_SIZE,
        )
        private val DEFAULT_ROOT_COLUMNS = arrayOf(
            Root.COLUMN_ROOT_ID,
            Root.COLUMN_FLAGS,
            Root.COLUMN_ICON,
            Root.COLUMN_TITLE,
            Root.COLUMN_SUMMARY,
            Root.COLUMN_DOCUMENT_ID
        )
    }

    override fun onCreate(): Boolean = true

    override fun queryRoots(projection: Array<String>?): Cursor = MatrixCursor(projection ?: DEFAULT_ROOT_COLUMNS).apply {
        newRow().apply {
            add(Root.COLUMN_ROOT_ID, DEFAULT_ROOT_ID)
            add(Root.COLUMN_FLAGS, Root.FLAG_LOCAL_ONLY)
            add(Root.COLUMN_ICON, R.mipmap.ic_launcher)
            add(Root.COLUMN_TITLE, context!!.getString(R.string.bett_box))
            add(Root.COLUMN_SUMMARY, "Data")
            add(Root.COLUMN_DOCUMENT_ID, "/")
        }
    }

    override fun queryChildDocuments(
        parentDocumentId: String,
        projection: Array<String>?,
        sortOrder: String?
    ): Cursor {
        val result = MatrixCursor(resolveDocumentProjection(projection))
        val parentFile = (if (parentDocumentId == "/") context?.filesDir else File(parentDocumentId))
            ?: throw FileNotFoundException("Parent directory not found")
        parentFile.listFiles()?.forEach { includeFile(result, it) }
        return result
    }

    override fun queryDocument(documentId: String, projection: Array<String>?): Cursor =
        MatrixCursor(resolveDocumentProjection(projection)).apply { includeFile(this, File(documentId)) }

    override fun openDocument(
        documentId: String,
        mode: String,
        signal: CancellationSignal?
    ): ParcelFileDescriptor = ParcelFileDescriptor.open(File(documentId), ParcelFileDescriptor.parseMode(sanitizeMode(mode)))

    private fun sanitizeMode(mode: String): String {
        val hasR = mode.contains('r')
        val hasW = mode.contains('w')
        val hasT = mode.contains('t')
        val hasA = mode.contains('a')
        return when {
            hasR && hasW && hasT -> "rwt"
            hasR && hasW -> "rw"
            hasW && hasT -> "wt"
            hasW && hasA -> "wa"
            hasW -> "w"
            else -> "r"
        }
    }

    private fun includeFile(result: MatrixCursor, file: File) {
        result.newRow().apply {
            add(Document.COLUMN_DOCUMENT_ID, file.absolutePath)
            add(Document.COLUMN_DISPLAY_NAME, file.name)
            add(Document.COLUMN_SIZE, file.length())
            add(Document.COLUMN_FLAGS, Document.FLAG_SUPPORTS_WRITE or Document.FLAG_SUPPORTS_DELETE)
            add(Document.COLUMN_MIME_TYPE, getDocumentType(file))
        }
    }

    private fun getDocumentType(file: File): String =
        if (file.isDirectory) Document.MIME_TYPE_DIR else "application/octet-stream"

    private fun resolveDocumentProjection(projection: Array<String>?): Array<String> = projection ?: DEFAULT_DOCUMENT_COLUMNS
}
