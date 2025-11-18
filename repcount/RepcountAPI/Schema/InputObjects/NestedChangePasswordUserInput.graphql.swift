// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  struct NestedChangePasswordUserInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      id: GadgetID,
      currentPassword: GraphQLNullable<String> = nil,
      newPassword: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "id": id,
        "currentPassword": currentPassword,
        "newPassword": newPassword
      ])
    }

    var id: GadgetID {
      get { __data["id"] }
      set { __data["id"] = newValue }
    }

    var currentPassword: GraphQLNullable<String> {
      get { __data["currentPassword"] }
      set { __data["currentPassword"] = newValue }
    }

    var newPassword: GraphQLNullable<String> {
      get { __data["newPassword"] }
      set { __data["newPassword"] = newValue }
    }
  }

}