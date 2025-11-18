// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  struct NestedResetPasswordUserInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      password: GraphQLNullable<String> = nil,
      code: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "password": password,
        "code": code
      ])
    }

    var password: GraphQLNullable<String> {
      get { __data["password"] }
      set { __data["password"] = newValue }
    }

    var code: GraphQLNullable<String> {
      get { __data["code"] }
      set { __data["code"] = newValue }
    }
  }

}