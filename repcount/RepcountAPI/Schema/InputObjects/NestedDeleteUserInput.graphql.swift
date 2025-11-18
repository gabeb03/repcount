// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  struct NestedDeleteUserInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      id: GadgetID
    ) {
      __data = InputDict([
        "id": id
      ])
    }

    var id: GadgetID {
      get { __data["id"] }
      set { __data["id"] = newValue }
    }
  }

}