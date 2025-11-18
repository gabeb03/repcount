// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  struct NestedVerifyEmailUserInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      code: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "code": code
      ])
    }

    var code: GraphQLNullable<String> {
      get { __data["code"] }
      set { __data["code"] = newValue }
    }
  }

}