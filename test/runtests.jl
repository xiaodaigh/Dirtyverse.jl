using DataFrames, TidyStanza
using Test

include("relocate-test.jl")

df = DataFrame(x = repeat(1:3, inner = 2, outer = 2),
       a = repeat(4:6, inner = 2, outer = 2),
       b = repeat(7:9, inner = 2, outer = 2),
       val1 = ["ce_val1_1","cf_val1_1","ce_val1_2","cf_val1_2","ce_val1_3","cf_val1_3","de_val1_1","df_val1_1","de_val1_2","df_val1_2","de_val1_3","df_val1_3"],
       val2 = ["ce_val2_1","cf_val2_1","ce_val2_2","cf_val2_2","ce_val2_3","cf_val2_3","de_val2_1","df_val2_1","de_val2_2","df_val2_2","de_val2_3","df_val2_3"],
       cname1 = repeat(["c", "d"], inner = 6),
       cname2 = repeat(["e", "f"], 6)
)

wider_df1 = DataFrame(
    x = repeat(1:3, inner=2),
    a =  repeat(4:6, inner=2),
    b =  repeat(7:9, inner=2),
    cname2 = repeat(["e", "f"], 3),
    val1_c = ["ce_val1_1","cf_val1_1", "ce_val1_2", "cf_val1_2", "ce_val1_3", "cf_val1_3"],
    val1_d = ["de_val1_1","df_val1_1", "de_val1_2", "df_val1_2", "de_val1_3", "df_val1_3"],
    val2_c = ["ce_val2_1","cf_val2_1", "ce_val2_2", "cf_val2_2", "ce_val2_3", "cf_val2_3"],
    val2_d = ["de_val2_1","df_val2_1", "de_val2_2", "df_val2_2", "de_val2_3", "df_val2_3"]
)

wider_df2 = DataFrame(
    x = repeat(1:3, inner = 4),
    a = repeat(4:6, inner = 4),
    b = repeat(7:9, inner = 4),
    val2 = ["ce_val2_1","cf_val2_1","de_val2_1","df_val2_1","ce_val2_2","cf_val2_2","de_val2_2","df_val2_2","ce_val2_3","cf_val2_3","de_val2_3","df_val2_3"],
    val1_c_e = vcat("ce_val1_1", repeat([missing],3), "ce_val1_2",repeat([missing],3),  "ce_val1_3", repeat([missing],3) ),
    val1_c_f = vcat(repeat([missing],1), "cf_val1_1", repeat([missing],3), "cf_val1_2",repeat([missing],3),  "cf_val1_3", repeat([missing],2) ),
    val1_d_e = vcat(repeat([missing],2), "de_val1_1", repeat([missing],3), "de_val1_2",repeat([missing],3),  "de_val1_3", repeat([missing],1) ),
    val1_d_f = vcat(repeat([missing],3), "df_val1_1", repeat([missing],3), "df_val1_2",repeat([missing],3),  "df_val1_3")
)

wider_df3 = DataFrame(
    x = 1:3,
    a = 4:6,
    b = 7:9,
    val1_c_e = ["ce_val1_1", "ce_val1_2", "ce_val1_3"],
    val1_c_f = ["cf_val1_1", "cf_val1_2", "cf_val1_3"],
    val1_d_e = ["de_val1_1", "de_val1_2", "de_val1_3"],
    val1_d_f = ["df_val1_1", "df_val1_2", "df_val1_3"],
    val2_c_e = ["ce_val2_1", "ce_val2_2", "ce_val2_3"],
    val2_c_f = ["cf_val2_1", "cf_val2_2", "cf_val2_3"],
    val2_d_e = ["de_val2_1", "de_val2_2", "de_val2_3"],
    val2_d_f = ["df_val2_1", "df_val2_2", "df_val2_3"]
)


df_noid = DataFrame(t = [:a, :b, :c, :a, :b, :c], x = 1:6, y = 11:16)
df_noid_res = DataFrame(
    x_a = [1 , missing, missing, 4, missing, missing],
    x_b = [missing, 2, missing, missing, 5, missing],
    x_c = [missing, missing, 3, missing, missing, 6],
    y_a = [11 , missing, missing, 14, missing, missing],
    y_b = [missing, 12, missing, missing, 15, missing],
    y_c = [missing, missing, 13, missing, missing, 16],
)

@testset "TidyStanza.jl" begin
    # Write your tests here.
    @test pivot_wider(df, names_from = :cname1, values_from = [:val1,:val2]) == wider_df1
    @test isequal(pivot_wider(df, names_from = [:cname1, :cname2], values_from = :val1),wider_df2)
    @test pivot_wider(df, names_from = [:cname1,:cname2], values_from = [:val1,:val2]) == wider_df3
    @test pivot_wider(df, names_from = "cname1", values_from = ["val1","val2"]) == wider_df1
    @test isequal(pivot_wider(df, names_from = ["cname1", "cname2"], values_from = "val1"),wider_df2)
    @test pivot_wider(df, names_from = ["cname1", "cname2"], values_from = ["val1","val2"]) == wider_df3
    @test isequal(pivot_wider(df_noid, names_from = [:t], values_from = [:x, :y]), df_noid_res)
end


