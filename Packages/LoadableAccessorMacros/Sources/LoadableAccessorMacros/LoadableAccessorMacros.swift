@attached(member, names: arbitrary)
public macro LoadableAccessors() =
    #externalMacro(
        module: "LoadableAccessorMacrosPlugin",
        type: "LoadableAccessorsMacro"
    )
