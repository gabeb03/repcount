// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  struct SignUpMutation: GraphQLMutation {
    static let operationName: String = "SignUp"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation SignUp($email: String!, $password: String!) { signUpUser(email: $email, password: $password) { __typename success errors { __typename message code } } }"#
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
        .field("signUpUser", SignUpUser?.self, arguments: [
          "email": .variable("email"),
          "password": .variable("password")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        SignUpMutation.Data.self
      ] }

      var signUpUser: SignUpUser? { __data["signUpUser"] }

      /// SignUpUser
      ///
      /// Parent Type: `SignUpUserResult`
      struct SignUpUser: RepcountAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Objects.SignUpUserResult }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("success", Bool.self),
          .field("errors", [Error_SelectionSet]?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          SignUpMutation.Data.SignUpUser.self
        ] }

        var success: Bool { __data["success"] }
        var errors: [Error_SelectionSet]? { __data["errors"] }

        /// SignUpUser.Error_SelectionSet
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
            SignUpMutation.Data.SignUpUser.Error_SelectionSet.self
          ] }

          /// The human facing error message for this error.
          var message: String { __data["message"] }
          /// The Gadget platform error code for this error.
          var code: String { __data["code"] }
        }
      }
    }
  }

}