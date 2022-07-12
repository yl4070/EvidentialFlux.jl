using EvidentialFlux
using Flux
using UnicodePlots


function gendata(n)
    x1 = randn(Float32, 2, n)
    x2 = randn(Float32, 2, n) .+ [2, 2]
    x3 = randn(Float32, 2, n) .+ [-2, 2]
    y1 = vcat(ones(Float32, n), zeros(Float32, 2 * n))
    y2 = vcat(zeros(Float32, n), ones(Float32, n), zeros(Float32, n))
    y3 = vcat(zeros(Float32, n), zeros(Float32, n), ones(Float32, n))
    hcat(x1, x2, x3), hcat(y1, y2, y3)'
end
n = 200
X, y = gendata(n)

# See the data
p = scatterplot(X[1, 1:n], X[2, 1:n], color = :green, width = 80, height = 30)
scatterplot!(p, X[1, (n+1):(n+n)], X[2, (n+1):(n+n)], color = :red)

m = Chain(Dense(2 => 30), DIR(30 => 3))
opt = Flux.Optimise.AdamW(0.01)
p = Flux.params(m)

epochs = 500
trnlosses = zeros(epochs)
for e in 1:epochs
    local trnloss = 0
    grads = Flux.gradient(p) do
        α = m(X)
        trnloss = dirloss(y, α, e)
        trnloss
    end
    trnlosses[e] = trnloss
    Flux.Optimise.update!(opt, p, grads)
end
scatterplot(1:epochs, trnlosses, width = 80, height = 30)

α̂ = m(X)
ŷ = α̂ ./ sum(α̂, dims = 1)
u = uncertainty(α̂)

GLMakie.heatmap(-5:0.1:5, -5:0.1:5, (x, y) -> uncertainty(m(vcat(x, y)))[1])
GLMakie.scatter!(X[1, y[1, :].==1], X[2, y[1, :].==1], color = :red)
GLMakie.scatter!(X[1, y[2, :].==1], X[2, y[2, :].==1], color = :green)
GLMakie.scatter!(X[1, y[3, :].==1], X[2, y[3, :].==1], color = :blue)

