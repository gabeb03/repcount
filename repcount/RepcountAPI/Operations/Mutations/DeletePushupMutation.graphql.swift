// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  struct DeletePushupMutation: GraphQLMutation {
    static let operationName: String = "DeletePushup"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation DeletePushup($id: GadgetID!) { deletePushup(id: $id) { __typename success errors { __typename message code } } }"#
      ))

    public var id: GadgetID

    public init(id: GadgetID) {
      self.id = id
    }

    @_spi(Unsafe) public var __variables: Variables? { ["id": id] }

    struct Data: RepcountAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("deletePushup", DeletePushup?.self, arguments: ["id": .variable("id")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        DeletePushupMutation.Data.self
      ] }

      var deletePushup: DeletePushup? { __data["deletePushup"] }

      /// DeletePushup
      ///
      /// Parent Type: `DeletePushupResult`
      struct DeletePushup: RepcountAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Objects.DeletePushupResult }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("success", Bool.self),
          .field("errors", [Error_SelectionSet]?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          DeletePushupMutation.Data.DeletePushup.self
        ] }

        var success: Bool { __data["success"] }
        var errors: [Error_SelectionSet]? { __data["errors"] }

        /// DeletePushup.Error_SelectionSet
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
            DeletePushupMutation.Data.DeletePushup.Error_SelectionSet.self
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