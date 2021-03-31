import tables

type ModID* = string

type Semver* = string

type SemVerConstraint* = string

type SPDXExpression* = string

type LocalizedString* = OrderedTable[string, string]

type Person* = object
  name: LocalizedString
  email: LocalizedString
  url: LocalizedString
  comment: LocalizedString

type ModIcons* = OrderedTable[string, string]

type ModDependency* = object
  version: SemVerConstraint
  optional: bool 

type ModDependencies* = OrderedTable[string, ModDependency] 

type FilePath* = string