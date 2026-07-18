import SwiftCompilerPlugin
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct LoadableAccessorsMacro: MemberMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw LoadableAccessorsMacroError.expectedStruct
        }

        let variableDeclarations = structDecl.memberBlock.members.compactMap {
            $0.decl.as(VariableDeclSyntax.self)
        }

        var existingNames = Set<String>()
        for variable in variableDeclarations {
            for binding in variable.bindings {
                if let identifier = binding.pattern.as(IdentifierPatternSyntax.self) {
                    existingNames.insert(identifier.identifier.text)
                }
            }
        }

        var generatedMembers: [DeclSyntax] = []
        var generatedNames = Set<String>()

        for variable in variableDeclarations {
            guard variable.bindings.count == 1,
                  let binding = variable.bindings.first,
                  let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self)
            else {
                continue
            }

            let resourceName = identifierPattern.identifier.text
            guard resourceName.hasSuffix("Resource") else {
                continue
            }

            guard let type = binding.typeAnnotation?.type.as(IdentifierTypeSyntax.self),
                  type.name.text == "Loadable",
                  let valueType = type.genericArgumentClause?.arguments.first?
                    .description
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            else {
                continue
            }

            let accessorName = String(resourceName.dropLast("Resource".count))
            guard !accessorName.isEmpty else {
                throw LoadableAccessorsMacroError.emptyAccessorName(resourceName)
            }
            guard !existingNames.contains(accessorName), !generatedNames.contains(accessorName) else {
                throw LoadableAccessorsMacroError.duplicateAccessorName(accessorName)
            }

            generatedNames.insert(accessorName)
            generatedMembers.append(
                """
                var \(raw: accessorName): \(raw: valueType) {
                    get {
                        \(raw: resourceName).valueOrEmpty
                    }
                    set {
                        \(raw: resourceName) = .loaded(newValue)
                    }
                }
                """
            )
        }

        return generatedMembers
    }
}

@main
struct LoadableAccessorMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        LoadableAccessorsMacro.self
    ]
}

private enum LoadableAccessorsMacroError: Error, CustomStringConvertible {
    case duplicateAccessorName(String)
    case emptyAccessorName(String)
    case expectedStruct

    var description: String {
        switch self {
        case .duplicateAccessorName(let name):
            "@LoadableAccessors cannot generate '\(name)' because that member already exists."
        case .emptyAccessorName(let resourceName):
            "@LoadableAccessors could not derive an accessor name from '\(resourceName)'."
        case .expectedStruct:
            "@LoadableAccessors can only be attached to a struct."
        }
    }
}
