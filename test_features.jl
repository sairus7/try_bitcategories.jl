
using Test
include("features.jl")

@testset "BinaryFeature" begin

f_vis = BinaryFeature{UInt}(:Vis, 0b0000001)
f_clk = BinaryFeature{UInt}(:Clk, 0b0000010)
f_mov = BinaryFeature{UInt}(:Mov, 0b0000100)

all = UInt(0b111)
vis = UInt(0b001)
clc = UInt(0b010)
mov = UInt(0b100)

all & f_vis.mask === f_vis.mask

@test name(f_vis) == :Vis
@test name(f_clk) == :Clk
@test name(f_mov) == :Mov

@test check(f_vis, all) == true
@test check(f_clk, all) == true
@test check(f_mov, all) == true

@test check(f_vis, mov) == false
@test check(f_clk, mov) == false
@test check(f_mov, mov) == true

end


@testset "ComplexFeature" begin

f_dir = ComplexFeature{UInt}(:Dir, 0b01111000,
    (:top, 0b00001000),
    (:down, 0b00010000),
    (:left, 0b00100000),
    (:right, 0b01000000)
)

no = UInt(1)
top = UInt(0b1010)
topleft = UInt(0b101000)

@test name(f_dir) == :Dir
@test value(f_dir, no) == :no
@test value(f_dir, top) == :top # first valid value
@test values(f_dir, topleft) == [:top, :left] # all values

@test check(f_dir, :top, topleft) == true
@test check(f_dir, :down, topleft) == false
@test check(f_dir, :left, topleft) == true
@test check(f_dir, :right, topleft) == false

end


@testset "FeatureSet" begin

f_set = FeatureSet{UInt}(:FSet,
    (:Vis, 0b0000001),
    (:Clk, 0b0000010),
    (:Mov, 0b0000100),
    (:Dir, 0b1111000,
        (:top, 0b0001000),
        (:down, 0b0010000),
        (:left, 0b0100000),
        (:right, 0b1000000)
    )
)

clk_topleft = UInt(0b0101010)
down = UInt(0b0010000)

@test value(f_set, :Dir, down) == (:Dir, :down)
@test check(f_set, (:Dir, :down), UInt(0x0012)) == true
@test values(f_set, clk_topleft) == [(:Clk,:Clk),(:Dir,[:top,:left])]
@test all_values(f_set, clk_topleft) == [(:Vis,:no),(:Clk,:Clk),(:Mov,:no),(:Dir,[:top,:left])]

end
