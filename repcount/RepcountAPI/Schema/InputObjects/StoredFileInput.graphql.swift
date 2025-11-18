// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  /// Input object supporting setting or updating a File field.
  struct StoredFileInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      base64: GraphQLNullable<String> = nil,
      file: GraphQLNullable<Upload> = nil,
      copyURL: GraphQLNullable<URL> = nil,
      directUploadToken: GraphQLNullable<String> = nil,
      mimeType: GraphQLNullable<String> = nil,
      fileName: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "base64": base64,
        "file": file,
        "copyURL": copyURL,
        "directUploadToken": directUploadToken,
        "mimeType": mimeType,
        "fileName": fileName
      ])
    }

    /// Sets the file contents using this string, interpreting the string as base64 encoded bytes. This is useful for creating files quickly and easily if you have the file contents available already, but, it doesn't support files larger than 10MB, and is slower to process for the backend. Using multipart file uploads or direct-to-storage file uploads is preferable.
    var base64: GraphQLNullable<String> {
      get { __data["base64"] }
      set { __data["base64"] = newValue }
    }

    /// Sets the file contents using binary bytes sent along side a GraphQL mutation as a multipart POST request. Gadget expects this multipart POST request to be formatted according to the GraphQL multipart request spec defined at https://github.com/jaydenseric/graphql-multipart-request-spec. Sending files as a multipart POST requests is supported natively by the generated Gadget JS client using File objects as variables in API calls. This method supports files up to 100MB.
    var file: GraphQLNullable<Upload> {
      get { __data["file"] }
      set { __data["file"] = newValue }
    }

    /// Sets the file contents by fetching a remote URL and saving a copy to cloud storage. File downloads happen as the request is processed so they can be validated, which means large files can take some time to download from the existing URL. If the file can't be fetched from this URL, the action will fail.
    var copyURL: GraphQLNullable<URL> {
      get { __data["copyURL"] }
      set { __data["copyURL"] = newValue }
    }

    /// Sets the file contents using a token from a separate upload request made with the Gadget storage service. Uploading files while a user is completing the rest of a form gives a great user experience and supports much larger files, but requires client side code to complete the upload, and then pass the returned token for this field.
    var directUploadToken: GraphQLNullable<String> {
      get { __data["directUploadToken"] }
      set { __data["directUploadToken"] = newValue }
    }

    /// Sets this file's mime type, which will then be used when serving the file during read requests as the `Content-Type` HTTP header. If not set, Gadget will infer a content type based on the file's contents.
    var mimeType: GraphQLNullable<String> {
      get { __data["mimeType"] }
      set { __data["mimeType"] = newValue }
    }

    /// Sets this file's stored name, which will then be used as the file name when serving the file during read requests. If not set, Gadget will infer a filename if possible.
    var fileName: GraphQLNullable<String> {
      get { __data["fileName"] }
      set { __data["fileName"] = newValue }
    }
  }

}