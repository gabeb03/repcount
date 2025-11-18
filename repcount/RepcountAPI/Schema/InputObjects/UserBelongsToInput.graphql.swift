// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  /// Input object supporting setting or updating related model record on a relationship field
  struct UserBelongsToInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      signUp: GraphQLNullable<NestedSignUpUserInput> = nil,
      signIn: GraphQLNullable<NestedSignInUserInput> = nil,
      signOut: GraphQLNullable<NestedSignOutUserInput> = nil,
      update: GraphQLNullable<NestedUpdateUserInput> = nil,
      delete: GraphQLNullable<NestedDeleteUserInput> = nil,
      sendVerifyEmail: GraphQLNullable<NestedSendVerifyEmailUserInput> = nil,
      verifyEmail: GraphQLNullable<NestedVerifyEmailUserInput> = nil,
      sendResetPassword: GraphQLNullable<NestedSendResetPasswordUserInput> = nil,
      resetPassword: GraphQLNullable<NestedResetPasswordUserInput> = nil,
      changePassword: GraphQLNullable<NestedChangePasswordUserInput> = nil,
      _link: GraphQLNullable<GadgetID> = nil
    ) {
      __data = InputDict([
        "signUp": signUp,
        "signIn": signIn,
        "signOut": signOut,
        "update": update,
        "delete": delete,
        "sendVerifyEmail": sendVerifyEmail,
        "verifyEmail": verifyEmail,
        "sendResetPassword": sendResetPassword,
        "resetPassword": resetPassword,
        "changePassword": changePassword,
        "_link": _link
      ])
    }

    var signUp: GraphQLNullable<NestedSignUpUserInput> {
      get { __data["signUp"] }
      set { __data["signUp"] = newValue }
    }

    var signIn: GraphQLNullable<NestedSignInUserInput> {
      get { __data["signIn"] }
      set { __data["signIn"] = newValue }
    }

    var signOut: GraphQLNullable<NestedSignOutUserInput> {
      get { __data["signOut"] }
      set { __data["signOut"] = newValue }
    }

    var update: GraphQLNullable<NestedUpdateUserInput> {
      get { __data["update"] }
      set { __data["update"] = newValue }
    }

    var delete: GraphQLNullable<NestedDeleteUserInput> {
      get { __data["delete"] }
      set { __data["delete"] = newValue }
    }

    var sendVerifyEmail: GraphQLNullable<NestedSendVerifyEmailUserInput> {
      get { __data["sendVerifyEmail"] }
      set { __data["sendVerifyEmail"] = newValue }
    }

    var verifyEmail: GraphQLNullable<NestedVerifyEmailUserInput> {
      get { __data["verifyEmail"] }
      set { __data["verifyEmail"] = newValue }
    }

    var sendResetPassword: GraphQLNullable<NestedSendResetPasswordUserInput> {
      get { __data["sendResetPassword"] }
      set { __data["sendResetPassword"] = newValue }
    }

    var resetPassword: GraphQLNullable<NestedResetPasswordUserInput> {
      get { __data["resetPassword"] }
      set { __data["resetPassword"] = newValue }
    }

    var changePassword: GraphQLNullable<NestedChangePasswordUserInput> {
      get { __data["changePassword"] }
      set { __data["changePassword"] = newValue }
    }

    /// Existing ID of another record, which you would like to associate this record with
    var _link: GraphQLNullable<GadgetID> {
      get { __data["_link"] }
      set { __data["_link"] = newValue }
    }
  }

}