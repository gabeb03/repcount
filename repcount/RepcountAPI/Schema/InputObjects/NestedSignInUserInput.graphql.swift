// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  struct NestedSignInUserInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      email: GraphQLNullable<String> = nil,
      password: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "email": email,
        "password": password
      ])
    }

    var email: GraphQLNullable<String> {
      get { __data["email"] }
      set { __data["email"] = newValue }
    }

    var password: GraphQLNullable<String> {
      get { __data["password"] }
      set { __data["password"] = newValue }
    }
  }

}