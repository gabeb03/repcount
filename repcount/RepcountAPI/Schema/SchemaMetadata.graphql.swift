// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

protocol RepcountAPI_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == RepcountAPI.SchemaMetadata {}

protocol RepcountAPI_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == RepcountAPI.SchemaMetadata {}

protocol RepcountAPI_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == RepcountAPI.SchemaMetadata {}

protocol RepcountAPI_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == RepcountAPI.SchemaMetadata {}

extension RepcountAPI {
  typealias SelectionSet = RepcountAPI_SelectionSet

  typealias InlineFragment = RepcountAPI_InlineFragment

  typealias MutableSelectionSet = RepcountAPI_MutableSelectionSet

  typealias MutableInlineFragment = RepcountAPI_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "CreatePushupResult": return RepcountAPI.Objects.CreatePushupResult
      case "DeletePushupResult": return RepcountAPI.Objects.DeletePushupResult
      case "InvalidRecordError": return RepcountAPI.Objects.InvalidRecordError
      case "Mutation": return RepcountAPI.Objects.Mutation
      case "Pushup": return RepcountAPI.Objects.Pushup
      case "PushupConnection": return RepcountAPI.Objects.PushupConnection
      case "PushupEdge": return RepcountAPI.Objects.PushupEdge
      case "Query": return RepcountAPI.Objects.Query
      case "SignInUserResult": return RepcountAPI.Objects.SignInUserResult
      case "SignUpUserResult": return RepcountAPI.Objects.SignUpUserResult
      case "SimpleError": return RepcountAPI.Objects.SimpleError
      case "UpdatePushupResult": return RepcountAPI.Objects.UpdatePushupResult
      case "UpdateUserResult": return RepcountAPI.Objects.UpdateUserResult
      case "UpsertError": return RepcountAPI.Objects.UpsertError
      case "User": return RepcountAPI.Objects.User
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}