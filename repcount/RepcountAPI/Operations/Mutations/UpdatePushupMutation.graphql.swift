// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  struct UpdatePushupMutation: GraphQLMutation {
    static let operationName: String = "UpdatePushup"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdatePushup($id: GadgetID!, $pushup: UpdatePushupInput) { updatePushup(id: $id, pushup: $pushup) { __typename success errors { __typename message code } pushup { __typename id numberOfPushups createdAt updatedAt } } }"#
      ))

    public var id: GadgetID
    public var pushup: GraphQLNullable<UpdatePushupInput>

    public init(
      id: GadgetID,
      pushup: GraphQLNullable<UpdatePushupInput>
    ) {
      self.id = id
      self.pushup = pushup
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "id": id,
      "pushup": pushup
    ] }

    struct Data: RepcountAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("updatePushup", UpdatePushup?.self, arguments: [
          "id": .variable("id"),
          "pushup": .variable("pushup")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UpdatePushupMutation.Data.self
      ] }

      var updatePushup: UpdatePushup? { __data["updatePushup"] }

      /// UpdatePushup
      ///
      /// Parent Type: `UpdatePushupResult`
      struct UpdatePushup: RepcountAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Objects.UpdatePushupResult }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("success", Bool.self),
          .field("errors", [Error_SelectionSet]?.self),
          .field("pushup", Pushup?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          UpdatePushupMutation.Data.UpdatePushup.self
        ] }

        var success: Bool { __data["success"] }
        var errors: [Error_SelectionSet]? { __data["errors"] }
        var pushup: Pushup? { __data["pushup"] }

        /// UpdatePushup.Error_SelectionSet
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
            UpdatePushupMutation.Data.UpdatePushup.Error_SelectionSet.self
          ] }

          /// The human facing error message for this error.
          var message: String { __data["message"] }
          /// The Gadget platform error code for this error.
          var code: String { __data["code"] }
        }

        /// UpdatePushup.Pushup
        ///
        /// Parent Type: `Pushup`
        struct Pushup: RepcountAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Objects.Pushup }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", RepcountAPI.GadgetID.self),
            .field("numberOfPushups", Double.self),
            .field("createdAt", RepcountAPI.DateTime.self),
            .field("updatedAt", RepcountAPI.DateTime.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            UpdatePushupMutation.Data.UpdatePushup.Pushup.self
          ] }

          /// The globally unique, unchanging identifier for this record. Assigned and managed by Gadget.
          var id: RepcountAPI.GadgetID { __data["id"] }
          var numberOfPushups: Double { __data["numberOfPushups"] }
          /// The time at which this record was first created. Set once upon record creation and never changed. Managed by Gadget.
          var createdAt: RepcountAPI.DateTime { __data["createdAt"] }
          /// The time at which this record was last changed. Set each time the record is successfully acted upon by an action. Managed by Gadget.
          var updatedAt: RepcountAPI.DateTime { __data["updatedAt"] }
        }
      }
    }
  }

}