# Emmanuel Murray Leclair
# February 2021
# Optimal Carbon Tax Simulation
mkpath("Figures")
using SparseArrays
using Random, Distributions
using Statistics
using LinearAlgebra
using Plots
using Interpolations
using Dierckx
using ForwardDiff
using Optim
    using Optim: converged, maximum, maximizer, minimizer, iterations
using Roots
using Parameters

#-----------------------------------------------------------
#-----------------------------------------------------------
# Paramters and Model Structure
    # Generate structure for parameters using Parameters module
    # We can set default values for our parameters
    @with_kw struct Par
        # Model Parameters
        γ_g::Float64 = 1 # Pollution intensity of natural gas (normalized)
        γ_c::Float64 = 2 # Pollution intensity of coal
        ρ::Float64   = 0.5 # Fraction of R&D spending that maps to productivity
        p_g::Float64 = 1 # Price of naturag gas (normalized to one)
        p_c::Float64 = 1 # Price of coal (normalized to one)
        β_g::Float64 = 0.8 # Share of natural gas in production of energy
        β_c::Float64 = 0.2 # Share of coal in production of energy
        σ::Float64   = 2 # Elasticity of sbustitution across fuels
        η::Float64   = 0.9 # Degree of returns to scale
        β::Float64   = 0.98 # Discount factor
        A_g1::Float64= 1 # Productivity of natural gas at t=1
        A_c1::Float64= 1 # Productivity of coal at t=1

        ## VFI Paramters
        #max_iter::Int64   = 100000; # Maximum number of iterations
        #dist_tol::Float64 = 1E-6  ; # Tolerance for distance
        ## Histogram iteration parameters
        #Hist_max_iter     = 10000 ;
        #Hist_tol          = 1E-5  ;
        ## Histogram iteration parameters
        #N_eq              = 1000  ;
        #tol_eq            = 1E-6  ;
        ## Minimum consumption for numerical optimization
        #c_min::Float64    = 1E-16
    end

    # Allocate paramters to object p for future calling
    p = Par()

# Efficiency-adjusted prices of coal, natural gas and energy index
function p_efficient(τ_c,τ_g,p::Par)
    @unpack p_g,p_c,σ,β_g,β_c,A_g1,A_c1=p
    p_eff_g = (p_g*(1+τ_g))/(β_g*A_g1)
    p_eff_c = (p_c*(1+τ_c))/(β_c*A_c1)
    p_eff_e = (p_eff_g^(1-σ)+p_eff_c^(1-σ))^(1/(1-σ))
    return (p_eff_g,p_eff_c,p_eff_e)
end
# Function to get marginal cost of energy
function MC_e(τ_c,τ_g,p_eff_g,p_eff_c,p_eff_e,p::Par)
    @unpack σ,A_g1,A_c1,p_c,p_g=p
    MC_c = (1+τ_c)*p_c*((p_eff_c/p_eff_e)^(-σ))*(1/A_c1)
    MC_g = (1+τ_g)*p_g*((p_eff_g/p_eff_e)^(-σ))*(1/A_g1)
    return MC_c + MC_g
end
# Function to get productivity of energy at t=2 as a function of R&D
function A_e2(A_e1::Float64,R,p::Par)
    @unpack ρ=p
    return A_e1 + ρ*R
end
# Function to get optimal energy choice
function E(A_e,MC_e,p::Par)
    @unpack η=p
    return ((MC_e/η)^(1/(η-1)))*(1/A_e)
end
# Function to get optimal R&D expenditure
function RD(A_e,MC_e,p::Par)
    @unpack β,ρ,η = p
    f_RD(x) = x[1]*((A_e+ρ*x[1])^2)-(β*ρ*((MC_e^(-η/(1-η)))*(η^(1/(1-η)))))
    min_result = optimize(x->f_RD(x).^2,[0.1,],LBFGS())
    #min_result = optimize(x->f_RD(x).^2,0.0,10000,Brent())
    return min_result.minimizer
end
# Function to get total GHG emissions as a function of tax rate
function GHG_func(p_eff_g,p_eff_c,p_eff_e,E,p::Par)
    @unpack σ,A_c1,A_g1,γ_g,γ_c=p
    q_c = E*(1/A_c1)*(p_eff_c/p_eff_e)^(-σ)
    q_g = E*(1/A_g1)*(p_eff_g/p_eff_e)^(-σ)
    return γ_g*q_g + γ_c*q_c
end

# Function that evaluates the fit of a given implied tax rate to generate desired GHG emissions
function τ_implied_objfunc(A_e,GHG,τ,type::Int64,p::Par)
    @unpack γ_g,γ_c=p
    if type == 1     # "Carbon" tax
        τ_g = τ[1]
        τ_c = (γ_c/γ_g)*τ[1]
    elseif type == 2 # "Fuel" tax
        τ_g = τ[1]
        τ_c = τ[1]
    end
    (p_eff_g,p_eff_c,p_eff_e) = p_efficient(τ_c,τ_g,p) # Efficiency-adjusted prices
    MC = MC_e(τ_c,τ_g,p_eff_g,p_eff_c,p_eff_e,p)       # Marginal cost of energy
    R_D = RD(A_e,MC,p)[1]                                  # Optimal R&D
    Ae2 = A_e2(A_e,R_D,p)                              # Energy productivity at t=2
    E1 = E(A_e,MC,p)                                   # Optimal energy level at t=1
    E2 = E(Ae2,MC,p)                                   # Optimal energy level at t=2
    ghg_1 = GHG_func(p_eff_g,p_eff_c,p_eff_e,E1,p)     # GHG emissions at t=1 generated from τ
    ghg_2 = GHG_func(p_eff_g,p_eff_c,p_eff_e,E2,p)     # GHG emissions at t=2 generated from τ
    GHG_implied = ghg_1+ghg_2
    return (GHG-GHG_implied).^2
end

# Function that finds the implied tax rate that generates desired GHG emissions
function τ_implied(A_e,GHG,type::Int64,p::Par)
    #min_result = optimize(x->τ_implied_objfunc(A_e,GHG,x,type,p),[0.0,],LBFGS())
    min_result = optimize(x->τ_implied_objfunc(A_e,GHG,x,type,p),0.0,100,Brent())
    return min_result.minimizer
end

# Function that evaluates the output and profit loss of a given implied tax rate to generate desired GHG emissions
function output_loss(A_e,τ,type::Int64,p::Par)
    @unpack γ_g,γ_c,η,β=p
    if type == 1     # "Carbon" tax
        τ_g = τ[1]
        τ_c = (γ_c/γ_g)*τ[1]
    elseif type == 2 # "Fuel" tax
        τ_g = τ[1]
        τ_c = τ[1]
    end
    (p_eff_g,p_eff_c,p_eff_e) = p_efficient(τ_c,τ_g,p) # Efficiency-adjusted prices
    MC = MC_e(τ_c,τ_g,p_eff_g,p_eff_c,p_eff_e,p)       # Marginal cost of energy
    R_D = RD(A_e,MC,p)[1]                                  # Optimal R&D
    Ae2 = A_e2(A_e,R_D,p)                              # Energy productivity at t=2
    E1 = E(A_e,MC,p)                                   # Optimal energy level at t=1
    E2 = E(Ae2,MC,p)                                   # Optimal energy level at t=2
    return ((A_e*E1)^η)+β*((Ae2*E2)^η)                 # Output
end

# No carbon-tax case
(p_eff_g_notax,p_eff_c_notax,p_eff_e_notax) = p_efficient(0.0,0.0,p) # efficency-adjusted prices
MC_notax = MC_e(0.0,0.0,p_eff_g_notax,p_eff_c_notax,p_eff_e_notax,p) # marginal cost
A_e1=1.0 # normalize productiviy of energy at t=1 to be 1
RD_notax = RD(A_e1,MC_notax,p)[1] # Optimal R&D spending
A_e2_notax = A_e2(A_e1,RD_notax,p) # Productivity of energy in period 2
E1_notax = E(A_e1,MC_notax,p) # Energy used in period 1
E2_notax = E(A_e2_notax,MC_notax,p) # Energy used in period 2
ghg_1_notax = GHG_func(p_eff_c_notax,p_eff_g_notax,p_eff_e_notax,E1_notax,p)
ghg_2_notax = GHG_func(p_eff_c_notax,p_eff_g_notax,p_eff_e_notax,E2_notax,p)
#(ghg_1_notax,ghg_2_notax) = GHG(p_eff_c_notax,p_eff_g_notax,p_eff_e_notax,E1_notax,E2_notax,p)
ghg_ub = ghg_1_notax+ghg_2_notax  # The no-tax case corresponds to an upper bound on GHG emissions

# Grid for desired GHG emissions:
n_fine = 1000
ghg_grid = collect(range(0.0,ghg_ub,length=n_fine))
# Implied tax rate
τ_carbon = Array{Float64}(undef, n_fine, 1)
τ_fuel = Array{Float64}(undef, n_fine, 1)
for i in 1:n_fine
    τ_carbon[i,1] = τ_implied(A_e1,ghg_grid[i],1,p)[1]
    τ_fuel[i,1] = τ_implied(A_e1,ghg_grid[i],2,p)[1]
end
# Output loss associated with each level of GHG emissions
output_loss_carbontax = Array{Float64}(undef, n_fine, 1)
output_loss_fueltax = Array{Float64}(undef, n_fine, 1)
for i in 1:n_fine
    output_loss_carbontax[i,1] = output_loss(A_e1,τ_carbon[i,1],1,p)[1]
    output_loss_fueltax[i,1] = output_loss(A_e1,τ_fuel[i,1],2,p)[1]
end
