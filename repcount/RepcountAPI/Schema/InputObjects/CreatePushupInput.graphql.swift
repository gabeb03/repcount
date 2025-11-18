// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  struct CreatePushupInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      user: GraphQLNullable<UserBelongsToInput> = nil,
      numberOfPushups: GraphQLNullable<Double> = nil
    ) {
      __data = InputDict([
        "user": user,
        "numberOfPushups": numberOfPushups
      ])
    }

    var user: GraphQLNullable<UserBelongsToInput> {
      get { __data["user"] }
      set { __data["user"] = newValue }
    }

    var numberOfPushups: GraphQLNullable<Double> {
      get { __data["numberOfPushups"] }
      set { __data["numberOfPushups"] = newValue }
    }
  }

}