import BaseToCore "BaseToCore";
import OrderedMap "mo:base/OrderedMap";
import ListBase "mo:base/List";
import Map "mo:core/Map";
import Text "mo:core/Text";
import Principal "mo:core/Principal";

module {
  // Custom types duplicated from main.mo (cannot import main.mo)
  type Page = {
    pageNumber : Nat;
    text : Text;
    imageUrl : ?Text;
    layout : PageLayout;
  };

  type PageLayout = {
    textPosition : TextPosition;
    imagePosition : ImagePosition;
  };

  type TextPosition = {
    x : Float;
    y : Float;
    width : Float;
    height : Float;
  };

  type ImagePosition = {
    x : Float;
    y : Float;
    width : Float;
    height : Float;
  };

  type CoverSpec = {
    front : CoverElement;
    back : CoverElement;
    spine : SpineSpec;
    dimensions : Dimensions;
    bleed : BleedSpec;
  };

  type CoverElement = {
    imageUrl : ?Text;
    text : Text;
    layout : Layout;
  };

  type SpineSpec = {
    width : Float;
    text : Text;
  };

  type Dimensions = {
    width : Float;
    height : Float;
  };

  type Layout = {
    position : Position;
    size : Size;
  };

  type Position = {
    x : Float;
    y : Float;
  };

  type Size = {
    width : Float;
    height : Float;
  };

  type ProjectSettings = {
    font : Text;
    fontSize : Float;
    margin : Float;
    lineSpacing : Float;
  };

  type Image = {
    id : Text;
    path : Text;
    projectId : Text;
    owner : Principal;
    pageId : ?Text;
    uploaded : Int;
    dpi : Float;
  };

  type KDPValidation = {
    isValid : Bool;
    errors : [Text];
    warnings : [Text];
    trimSize : Dimensions;
    bleed : BleedSpec;
    margin : MarginSpec;
    spineWidth : Float;
  };

  type BleedSpec = {
    top : Float;
    bottom : Float;
    left : Float;
    right : Float;
  };

  type MarginSpec = {
    top : Float;
    bottom : Float;
    left : Float;
    right : Float;
  };

  type UserProfile = {
    name : Text;
  };

  type Project = {
    id : Text;
    title : Text;
    owner : Principal;
    createdAt : Int;
    updatedAt : Int;
    story : Text;
    pages : [Page];
    cover : CoverSpec;
    settings : ProjectSettings;
    kdpValidation : KDPValidation;
  };

  // FileReference type from old blob-storage/registry module
  type FileReference = { hash : Text; path : Text };

  // OldActor: state as it was with mo:base OrderedMap (including old registry)
  public type OldActor = {
    accessControlState : BaseToCore.OldAccessControlState;
    var projects : OrderedMap.Map<Text, Project>;
    var images : OrderedMap.Map<Text, Image>;
    var userProfiles : OrderedMap.Map<Principal, UserProfile>;
    var fileOwnership : OrderedMap.Map<Text, Principal>;
    var projectOwners : OrderedMap.Map<Text, Principal>;
    var nextProjectId : Nat;
    // Old vendored blob-storage registry — discarded during migration
    registry : {
      var authorizedPrincipals : [Principal];
      var blobsToRemove : OrderedMap.Map<Text, Bool>;
      var references : OrderedMap.Map<Text, FileReference>;
    };
  };

  // NewActor: state with mo:core Map
  public type NewActor = {
    accessControlState : BaseToCore.NewAccessControlState;
    var projects : Map.Map<Text, Project>;
    var images : Map.Map<Text, Image>;
    var userProfiles : Map.Map<Principal, UserProfile>;
    var fileOwnership : Map.Map<Text, Principal>;
    var projectOwners : Map.Map<Text, Principal>;
    var nextProjectId : Nat;
  };

  public func run(old : OldActor) : NewActor {
    {
      accessControlState = BaseToCore.migrateAccessControlState(old.accessControlState);
      var projects = BaseToCore.migrateOrderedMap<Text, Project>(old.projects);
      var images = BaseToCore.migrateOrderedMap<Text, Image>(old.images);
      var userProfiles = BaseToCore.migrateOrderedMap<Principal, UserProfile>(old.userProfiles);
      var fileOwnership = BaseToCore.migrateOrderedMap<Text, Principal>(old.fileOwnership);
      var projectOwners = BaseToCore.migrateOrderedMap<Text, Principal>(old.projectOwners);
      var nextProjectId = old.nextProjectId;
    };
  };
};
