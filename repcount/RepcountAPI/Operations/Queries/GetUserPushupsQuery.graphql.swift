// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension RepcountAPI {
  struct GetUserPushupsQuery: GraphQLQuery {
    static let operationName: String = "GetUserPushups"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query GetUserPushups($userId: GadgetID!) { pushups(filter: { user: { id: { equals: $userId } } }) { __typename edges { __typename node { __typename id numberOfPushups createdAt updatedAt user { __typename id email } } } } }"#
      ))

    public var userId: GadgetID

    public init(userId: GadgetID) {
      self.userId = userId
    }

    @_spi(Unsafe) public var __variables: Variables? { ["userId": userId] }

    struct Data: RepcountAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("pushups", Pushups.self, arguments: ["filter": ["user": ["id": ["equals": .variable("userId")]]]]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        GetUserPushupsQuery.Data.self
      ] }

      var pushups: Pushups { __data["pushups"] }

      /// Pushups
      ///
      /// Parent Type: `PushupConnection`
      struct Pushups: RepcountAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Objects.PushupConnection }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("edges", [Edge].self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          GetUserPushupsQuery.Data.Pushups.self
        ] }

        /// A list of edges.
        var edges: [Edge] { __data["edges"] }

        /// Pushups.Edge
        ///
        /// Parent Type: `PushupEdge`
        struct Edge: RepcountAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Objects.PushupEdge }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("node", Node.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            GetUserPushupsQuery.Data.Pushups.Edge.self
          ] }

          /// The item at the end of the edge
          var node: Node { __data["node"] }

          /// Pushups.Edge.Node
          ///
          /// Parent Type: `Pushup`
          struct Node: RepcountAPI.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Objects.Pushup }
            static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", RepcountAPI.GadgetID.self),
              .field("numberOfPushups", Double.self),
              .field("createdAt", RepcountAPI.DateTime.self),
              .field("updatedAt", RepcountAPI.DateTime.self),
              .field("user", User?.self),
            ] }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              GetUserPushupsQuery.Data.Pushups.Edge.Node.self
            ] }

            /// The globally unique, unchanging identifier for this record. Assigned and managed by Gadget.
            var id: RepcountAPI.GadgetID { __data["id"] }
            var numberOfPushups: Double { __data["numberOfPushups"] }
            /// The time at which this record was first created. Set once upon record creation and never changed. Managed by Gadget.
            var createdAt: RepcountAPI.DateTime { __data["createdAt"] }
            /// The time at which this record was last changed. Set each time the record is successfully acted upon by an action. Managed by Gadget.
            var updatedAt: RepcountAPI.DateTime { __data["updatedAt"] }
            var user: User? { __data["user"] }

            /// Pushups.Edge.Node.User
            ///
            /// Parent Type: `User`
            struct User: RepcountAPI.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { RepcountAPI.Objects.User }
              static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("id", RepcountAPI.GadgetID.self),
                .field("email", String.self),
              ] }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                GetUserPushupsQuery.Data.Pushups.Edge.Node.User.self
              ] }

              /// The globally unique, unchanging identifier for this record. Assigned and managed by Gadget.
              var id: RepcountAPI.GadgetID { __data["id"] }
              var email: String { __data["email"] }
            }
          }
        }
      }
    }
  }

}