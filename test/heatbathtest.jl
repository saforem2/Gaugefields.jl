function heatbath_SU2!(U,NC,temps,β)
    Dim = 4
    temp1 = temps[1]
    temp2 = temps[2]
    V = temps[3]
    ITERATION_MAX = 10^5

    mapfunc!(A,B) = SU2update_KP!(A,B,β,NC,ITERATION_MAX)

    for μ=1:Dim

        loops = loops_staple[(Dim,μ)]
        iseven = true

        evaluate_gaugelinks_evenodd!(V,loops,U,[temp1,temp2],iseven)
        map_U!(U[μ],mapfunc!,V,iseven) 

        iseven = false
        evaluate_gaugelinks_evenodd!(V,loops,U,[temp1,temp2],iseven)
        map_U!(U[μ],mapfunc!,V,iseven) 
    end
    
end

function heatbath_SU3!(U,NC,temps,β)
    Dim = 4
    temp1 = temps[1]
    temp2 = temps[2]
    V = temps[3]
    ITERATION_MAX = 10^5

    mapfunc!(A,B) = SU3update_matrix!(A,B,β,NC,ITERATION_MAX)

    for μ=1:Dim

        loops = loops_staple[(Dim,μ)]
        iseven = true

        evaluate_gaugelinks_evenodd!(V,loops,U,[temp1,temp2],iseven)
        map_U!(U[μ],mapfunc!,V,iseven) 

        iseven = false
        evaluate_gaugelinks_evenodd!(V,loops,U,[temp1,temp2],iseven)
        map_U!(U[μ],mapfunc!,V,iseven) 
    end
    
end


function heatbath_SUN!(U,NC,temps,β)
    Dim = 4
    temp1 = temps[1]
    temp2 = temps[2]
    V = temps[3]
    ITERATION_MAX = 10^5

    mapfunc!(A,B) = SUNupdate_matrix!(A,B,β,NC,ITERATION_MAX)

    for μ=1:Dim

        loops = loops_staple[(Dim,μ)]
        iseven = true

        evaluate_gaugelinks_evenodd!(V,loops,U,[temp1,temp2],iseven)
        map_U!(U[μ],mapfunc!,V,iseven) 

        iseven = false
        evaluate_gaugelinks_evenodd!(V,loops,U,[temp1,temp2],iseven)
        map_U!(U[μ],mapfunc!,V,iseven) 
    end
    
end


function heatbathtest_4D(NX,NY,NZ,NT,β,NC)
    Dim = 4
    Nwing = 1

    u1 = IdentityGauges(NC,Nwing,NX,NY,NZ,NT)
    U = Array{typeof(u1),1}(undef,Dim)
    U[1] = u1
    for μ=2:Dim
        U[μ] = IdentityGauges(NC,Nwing,NX,NY,NZ,NT)
    end

    temp1 = similar(U[1])
    temp2 = similar(U[1])
    temp3 = similar(U[1])

    comb = 6
    factor = 1/(comb*U[1].NV*U[1].NC)
    @time plaq_t = calculate_Plaquette(U,temp1,temp2)*factor
    println("plaq_t = $plaq_t")
    poly = calculate_Polyakov_loop(U,temp1,temp2) 
    println("polyakov loop = $(real(poly)) $(imag(poly))")

    numhb = 40
    for itrj = 1:numhb
        if NC == 2
            heatbath_SU2!(U,NC,[temp1,temp2,temp3],β)
        elseif NC == 3
            heatbath_SU3!(U,NC,[temp1,temp2,temp3],β)
        else
            heatbath_SUN!(U,NC,[temp1,temp2,temp3],β)
        end

        if itrj % 10 == 0
            @time plaq_t = calculate_Plaquette(U,temp1,temp2)*factor
            println("$itrj plaq_t = $plaq_t")
            poly = calculate_Polyakov_loop(U,temp1,temp2) 
            println("$itrj polyakov loop = $(real(poly)) $(imag(poly))")
        end
    end
    

    return plaq_t

end

eps = 1e-1


@testset "4D" begin
    NX = 4
    NY = 4
    NZ = 4
    NT = 4
    Nwing = 1
    
    @testset "NC=2" begin
        β = 2.3
        NC = 2
        println("NC = $NC")
        val =0.6414596466929057
        @time plaq_t = heatbathtest_4D(NX,NY,NZ,NT,β,NC)
        @test abs(plaq_t-val)/abs(val) < eps
    end

    @testset "NC=3" begin
        β = 5.7
        NC = 3
        println("NC = $NC")
        val = 0.5779454661484242
        @time plaq_t = heatbathtest_4D(NX,NY,NZ,NT,β,NC)
        @test abs(plaq_t-val)/abs(val) < eps
    end

    @testset "NC=4" begin
        β = 5.7
        NC = 4
        println("NC = $NC")
        val  =0.19127260002797497
        @time plaq_t = heatbathtest_4D(NX,NY,NZ,NT,β,NC)
        @test abs(plaq_t-val)/abs(val) < eps
    end


end