
"""
feature with two values
"""
struct BinaryFeature{T}
    name::Symbol
    mask::T
end
"""
get name of the feature itself
"""
function name(f::BinaryFeature{T}) where T
    f.name
end
"""
check if feature is present in data
"""
function check(f::BinaryFeature{T}, type::T) where T
    type & f.mask === f.mask # or: type & f.mask > 0
end
"""
check if feature is present and return its name or :no name
"""
function value(f::BinaryFeature{T}, type::T) where T
    if check(f, type)
        f.name
    else
        :no
    end
end
values(f::BinaryFeature{T}, type::T) where T = value(f, type)

"""
feature with more than two values
"""
struct ComplexFeature{T}
    name::Symbol
    mask::T
    features::Vector{BinaryFeature{T}}
end
function ComplexFeature{T}(name, mask, args...) where T
    # len = length(args)
    features = BinaryFeature{T}[]
    for (name, mask) in args
        push!(features, BinaryFeature{T}(name, mask))
    end
    ComplexFeature{T}(name, mask, features)
end

"""
get name of the feature itself
"""
function name(f::ComplexFeature{T}) where T
    f.name
end
"""
check if feature is present in data
"""
function check(f::ComplexFeature{T}, fname::Symbol, type::T) where T
    subtype = type & f.mask
    for feature in f.features # apply external mask
        if feature.name === fname
            return check(feature, subtype) # check inner mask
        end
    end
    return false
end
"""
check if feature is present and return its name or :no name
"""
function value(f::ComplexFeature{T}, type::T) where T
    subtype = type & f.mask # apply external mask
    for feature in f.features
        if check(feature, subtype) # check inner mask
            return feature.name
        end
    end
    return :no
end
"""
return vector of feature names present in data, or empty vector
"""
function values(f::ComplexFeature{T}, type::T) where T
    subtype = type & f.mask # apply external mask
    names = Vector{Symbol}(undef, 0)
    for feature in f.features
        if check(feature, subtype) # check inner mask
            push!(names, feature.name)
        end
    end
    return names
end
"""
check if feature is present and return its name or :no name
"""
struct FeatureSet{T}
    name::Symbol
    features::Vector{Union{BinaryFeature{T}, ComplexFeature{T}}}
end
function FeatureSet{T}(name, args...) where T
    len = length(args)
    features = Vector{Union{BinaryFeature{T}, ComplexFeature{T}}}(undef, 0)
    for feat_tuple in args
        if length(feat_tuple) == 2
            push!(features, BinaryFeature{T}(feat_tuple...)) # name, mask
        else
            push!(features, ComplexFeature{T}(feat_tuple...)) # name, mask
        end
    end
    FeatureSet{T}(name, features)
end
"""
get name of the featureset
"""
function name(f::FeatureSet{T}) where T
    f.name
end
"""
check if feature is present in data
"""
function check(f::FeatureSet{T}, fnameval, type::T) where T
    if isa(fnameval, Tuple)
        fname, fval = fnameval
    else
        fname = fval = fnameval
    end
    for feature in f.features # apply external mask
        if feature.name === fname
            return check(feature, fval, type)
        end
    end
    return false
end
"""
check if feature is present and return its name or :no name
"""
function value(f::FeatureSet{T}, fname::Symbol, type::T) where T
    for feature in f.features
        if feature.name === fname
            val = value(feature, type)
            if val !== :no
                return feature.name, val
            end
        end
    end
    return :no, :no
end
"""
return vector of feature names present in data, or empty vector
"""
function values(f::FeatureSet{T}, type::T) where T
    names = Vector{Tuple{Symbol, Union{Vector{Symbol}, Symbol}}}(undef, 0)
    for feature in f.features
        val = values(feature, type)
        if val !== :no
            push!(names, (feature.name, val))
        end
    end
    return names
end
"""
return vector of feature names present in data, or :no name for absent features
"""
function all_values(f::FeatureSet{T}, type::T) where T
    names = Vector{Tuple{Symbol, Union{Vector{Symbol}, Symbol}}}(undef, 0)
    for feature in f.features
        val = values(feature, type)
        if !(isa(val, Vector) && isempty(val)) # val !== :no
            push!(names, (feature.name, val))
        else # add :no to absent features
            push!(names, (feature.name, :no))
        end
    end
    return names
end
