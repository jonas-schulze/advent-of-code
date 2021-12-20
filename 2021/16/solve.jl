using Test

function read_bits(file)
    str = readchomp(file)
    bits = str2bits(str)
    return bits
end

function str2bits(str)
    bytes = hex2bytes(str)
    bits = Bool[]
    for byte in bytes
        chars = collect(bitstring(byte))
        _bits = chars .== '1'
        append!(bits, _bits)
    end
    return bits
end

function bits2num(bits, pos, len, num=0)
    for p in pos:pos+len-1
        b = bits[p]
        num *= 2
        num += b
    end
    return num
end

struct BITS
    version::Int
    type::Int
    content::Union{Int,Vector{BITS}}
end

function Base.:(==)(b1::BITS, b2::BITS)
    b1.version == b2.version &&
    b1.type == b2.type &&
    b1.content == b2.content
end

parse_bits(bits) = parse_bits(bits, 1)

function parse_bits(bits, pos)
    version = bits2num(bits, pos, 3)
    type = bits2num(bits, pos+3, 3)
    content, nextpos = if type == 4
        parse_literal_value(bits, pos+6)
    else
        parse_operator(bits, pos+6)
    end
    return BITS(version, type, content), nextpos
end

function parse_literal_value(bits, pos)
    val = 0
    while true
        notlast = bits[pos]
        val = bits2num(bits, pos+1, 4, val)
        pos += 5
        notlast || break
    end
    return val, pos
end

function parse_operator(bits, pos)
    subpackets = BITS[]
    # Check length type:
    if bits[pos]
        npackets = bits2num(bits, pos+1, 11)
        pos += 12
        for _ in 1:npackets
            packet, pos = parse_bits(bits, pos)
            push!(subpackets, packet)
        end
    else
        nbits = bits2num(bits, pos+1, 15)
        pos += 16
        lastpos = pos + nbits
        while pos < lastpos
            packet, pos = parse_bits(bits, pos)
            push!(subpackets, packet)
        end
    end
    return subpackets, pos
end

function sum_versions(packet::BITS)
    s = packet.version
    packet.type == 4 && return s
    s += sum(sum_versions(c) for c in packet.content)
    return s
end

function sum_versions(file::String)
    bits = read_bits(file)
    m, _ = parse_bits(bits)
    return sum_versions(m)
end

b1 = str2bits("D2FE28")
m1, p1 = parse_bits(b1)
@test m1 == BITS(6, 4, 2021)
@test p1 == length(b1) - 2 # 2+1 trailing zeros
@test sum_versions(m1) == 6

b2 = str2bits("38006F45291200")
m2, p2 = parse_bits(b2)
@test m2 == BITS(1, 6, [BITS(6, 4, 10), BITS(2, 4, 20)])
@test p2 == length(b2) - 6 # 6+1 trailing zeros
@test sum_versions(m2) == 9

@test sum_versions("test1.txt") == 16
@test sum_versions("test2.txt") == 12
@test sum_versions("test3.txt") == 23
@test sum_versions("test4.txt") == 31

b = read_bits("input.txt")
m, _ = parse_bits(b)
@show sum_versions(m)
