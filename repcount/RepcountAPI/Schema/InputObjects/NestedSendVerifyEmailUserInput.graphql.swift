// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  struct NestedSendVerifyEmailUserInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      email: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "email": email
      ])
    }

    var email: GraphQLNullable<String> {
      get { __data["email"] }
      set { __data["email"] = newValue }
    }
  }

}