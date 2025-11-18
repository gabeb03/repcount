// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  struct SignInMutation: GraphQLMutation {
    static let operationName: String = "SignIn"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation SignIn($email: String!, $password: String!) { signInUser(email: $email, password: $password) { __typename success errors { __typename message code } user { __typename _all } } }"#
      ))

    public var email: String
    public var password: String

    public init(
      email: String,
      password: String
    ) {
      self.email = email
      self.password = password
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "email": email,
      "password": password
    ] }

    struct Data: RepcountAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("signInUser", SignInUser?.self, arguments: [
          "email": .variable("email"),
          "password": .variable("password")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        SignInMutation.Data.self
      ] }

      var signInUser: SignInUser? { __data["signInUser"] }

      /// SignInUser
      ///
      /// Parent Type: `SignInUserResult`
      struct SignInUser: RepcountAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Objects.SignInUserResult }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("success", Bool.self),
          .field("errors", [Error_SelectionSet]?.self),
          .field("user", User?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          SignInMutation.Data.SignInUser.self
        ] }

        var success: Bool { __data["success"] }
        var errors: [Error_SelectionSet]? { __data["errors"] }
        var user: User? { __data["user"] }

        /// SignInUser.Error_SelectionSet
        ///
        /// Parent Type: `ExecutionError`
        struct Error_SelectionSet: RepcountAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Interfaces.ExecutionError }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("message", String.self),
            .field("code", String.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            SignInMutation.Data.SignInUser.Error_SelectionSet.self
          ] }

          /// The human facing error message for this error.
          var message: String { __data["message"] }
          /// The Gadget platform error code for this error.
          var code: String { __data["code"] }
        }

        /// SignInUser.User
        ///
        /// Parent Type: `User`
        struct User: RepcountAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Objects.User }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("_all", RepcountAPI.JSONObject.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            SignInMutation.Data.SignInUser.User.self
          ] }

          /// Get all the fields for this record. Useful for not having to list out all the fields you want to retrieve, but slower.
          var _all: RepcountAPI.JSONObject { __data["_all"] }
        }
      }
    }
  }

}