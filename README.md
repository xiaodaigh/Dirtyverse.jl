## TidyStanza

I am trying to implement {tidyverse}, including {dplyr}, APIs in Julia. This is not intended to be a sustained effort and is meant to be a fun exercise to learn {tidyverse} and teach Julia programming. So prolonged maintenance is purely accidental!

### Examples:

#### `across` and `where`

<details>

* `TidyStanza.Across` and `TidyStanza.across` are synonyms and have the same API as `dplyr::across`
* `TidyStanza.Where` and `TidyStanza.where` are synonyms and have the same API as `dplyr::across(where(...), ...)`

By default, they are NOT exported, and the recommended way is to use `TidyStanza.across` and `TidyStanza.where`
to refer to them.

```julia
import TidyStanza
const tidy = TidyStanza

tidy.across
tidy.where
```

```
where (generic function with 1 method)
```





However, in the examples below, for brevity, I have imported `across` and `where`
directly into the namespace.

```julia
using TidyStanza: across, where


### load some helper packages
using DataFrames
using Statistics # for using mean
using Pipe: @pipe # for @pipe macro
using RDatasets # for iris dataset

iris = dataset("datasets", "iris");

# a glimpse of the data
first(iris, 8)
```

```
8×5 DataFrame
 Row │ SepalLength  SepalWidth  PetalLength  PetalWidth  Species
     │ Float64      Float64     Float64      Float64     Cat…
─────┼───────────────────────────────────────────────────────────
   1 │         5.1         3.5          1.4         0.2  setosa
   2 │         4.9         3.0          1.4         0.2  setosa
   3 │         4.7         3.2          1.3         0.2  setosa
   4 │         4.6         3.1          1.5         0.2  setosa
   5 │         5.0         3.6          1.4         0.2  setosa
   6 │         5.4         3.9          1.7         0.4  setosa
   7 │         4.6         3.4          1.4         0.3  setosa
   8 │         5.0         3.4          1.5         0.2  setosa
```



```julia
# R"""
# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), mean))
# """

@pipe iris |>
  groupby(_, :Species) |>
  combine(_, across(startswith("Sepal"), mean))
```

```
3×3 DataFrame
 Row │ Species     SepalLength  SepalWidth
     │ Cat…        Float64      Float64
─────┼─────────────────────────────────────
   1 │ setosa            5.006       3.428
   2 │ versicolor        5.936       2.77
   3 │ virginica         6.588       2.974
```



```julia
using CategoricalArrays: CategoricalArray
# R"""
# iris %>%
    # as_tibble() %>%
    # mutate(across(where(is.factor), as.character))
# """

# define a convenience function for checking if column is categorical
iscatarray(arr) = typeof(arr) <: CategoricalArray

@pipe iris |>
  transform(_, across(where(iscatarray), Vector{String})) |>
  first(_, 8)

@pipe iris |>
  transform(_, across(where(iscatarray), col->string.(col))) |>
  first(_, 8)
```

```
8×5 DataFrame
 Row │ SepalLength  SepalWidth  PetalLength  PetalWidth  Species
     │ Float64      Float64     Float64      Float64     String
─────┼───────────────────────────────────────────────────────────
   1 │         5.1         3.5          1.4         0.2  setosa
   2 │         4.9         3.0          1.4         0.2  setosa
   3 │         4.7         3.2          1.3         0.2  setosa
   4 │         4.6         3.1          1.5         0.2  setosa
   5 │         5.0         3.6          1.4         0.2  setosa
   6 │         5.4         3.9          1.7         0.4  setosa
   7 │         4.6         3.4          1.4         0.3  setosa
   8 │         5.0         3.4          1.5         0.2  setosa
```



```julia
# A purrr-style formula
# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), ~mean(.x, na.rm = TRUE)))
@pipe iris |>
  groupby(_, :Species) |>
  combine(_, across(startswith("Sepal"), x->mean(x |> skipmissing)))
```

```
3×3 DataFrame
 Row │ Species     SepalLength  SepalWidth
     │ Cat…        Float64      Float64
─────┼─────────────────────────────────────
   1 │ setosa            5.006       3.428
   2 │ versicolor        5.936       2.77
   3 │ virginica         6.588       2.974
```



```julia
# A named list of functions
# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), list(mean = mean, sd = sd)))

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, across(startswith("Sepal"), (mean, std)))
```

```
3×5 DataFrame
 Row │ Species     SepalLength_mean  SepalWidth_mean  SepalLength_std  Sepa
lWi ⋯
     │ Cat…        Float64           Float64          Float64          Floa
t64 ⋯
─────┼─────────────────────────────────────────────────────────────────────
─────
   1 │ setosa                 5.006            3.428         0.35249       
  0 ⋯
   2 │ versicolor             5.936            2.77          0.516171      
  0
   3 │ virginica              6.588            2.974         0.63588       
  0
                                                                1 column om
itted
```



```julia
# Use the .names argument to control the output names
# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), mean, .names = "mean_{col}"))

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, across(startswith("Sepal"), mean; names = "mean_{col}"))
```

```
3×3 DataFrame
 Row │ Species     mean_SepalLength  mean_SepalWidth
     │ Cat…        Float64           Float64
─────┼───────────────────────────────────────────────
   1 │ setosa                 5.006            3.428
   2 │ versicolor             5.936            2.77
   3 │ virginica              6.588            2.974
```



```julia
# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), list(mean = mean, sd = sd), .names = "{col}_{fn}"))

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, across(startswith("Sepal"), (mean = mean, std = std); names = "{col}_{fn}"))
```

```
3×5 DataFrame
 Row │ Species     SepalLength_mean  SepalWidth_mean  SepalLength_std  Sepa
lWi ⋯
     │ Cat…        Float64           Float64          Float64          Floa
t64 ⋯
─────┼─────────────────────────────────────────────────────────────────────
─────
   1 │ setosa                 5.006            3.428         0.35249       
  0 ⋯
   2 │ versicolor             5.936            2.77          0.516171      
  0
   3 │ virginica              6.588            2.974         0.63588       
  0
                                                                1 column om
itted
```



```julia
# iris %>%
#   group_by(Species) %>%
#   summarise(across(starts_with("Sepal"), list(mean, sd), .names = "{col}.fn{fn}"))

@pipe iris |>
    groupby(_, :Species) |>
    combine(_, across(startswith("Sepal"), (mean, std); names = "{col}_fn{fn}"))
```

```
3×5 DataFrame
 Row │ Species     SepalLength_fn1  SepalWidth_fn1  SepalLength_fn2  SepalW
idt ⋯
     │ Cat…        Float64          Float64         Float64          Float6
4   ⋯
─────┼─────────────────────────────────────────────────────────────────────
─────
   1 │ setosa                5.006           3.428         0.35249         
0.3 ⋯
   2 │ versicolor            5.936           2.77          0.516171        
0.3
   3 │ virginica             6.588           2.974         0.63588         
0.3
                                                                1 column om
itted
```




</details>

#### `pivot_wider`

<details>

```julia
df = DataFrame(x = repeat(1:3,inner = 2,outer = 2),
       a = repeat(4:6,inner = 2,outer = 2),
       b = repeat(7:9,inner = 2,outer = 2),
       val1 = ["ce_val1_1","cf_val1_1","ce_val1_2","cf_val1_2","ce_val1_3","cf_val1_3","de_val1_1",
               "df_val1_1","de_val1_2","df_val1_2","de_val1_3","df_val1_3"],
       val2 = ["ce_val2_1","cf_val2_1","ce_val2_2","cf_val2_2","ce_val2_3","cf_val2_3","de_val2_1",
               "df_val2_1","de_val2_2","df_val2_2","de_val2_3","df_val2_3"],
       cname1 = repeat(["c", "d"], inner = 6),
       cname2 = repeat(["e", "f"], 6)
       )
```

```
12×7 DataFrame
 Row │ x      a      b      val1       val2       cname1  cname2
     │ Int64  Int64  Int64  String     String     String  String
─────┼───────────────────────────────────────────────────────────
   1 │     1      4      7  ce_val1_1  ce_val2_1  c       e
   2 │     1      4      7  cf_val1_1  cf_val2_1  c       f
   3 │     2      5      8  ce_val1_2  ce_val2_2  c       e
   4 │     2      5      8  cf_val1_2  cf_val2_2  c       f
   5 │     3      6      9  ce_val1_3  ce_val2_3  c       e
   6 │     3      6      9  cf_val1_3  cf_val2_3  c       f
   7 │     1      4      7  de_val1_1  de_val2_1  d       e
   8 │     1      4      7  df_val1_1  df_val2_1  d       f
   9 │     2      5      8  de_val1_2  de_val2_2  d       e
  10 │     2      5      8  df_val1_2  df_val2_2  d       f
  11 │     3      6      9  de_val1_3  de_val2_3  d       e
  12 │     3      6      9  df_val1_3  df_val2_3  d       f
```



```julia
using TidyStanza: pivot_wider
pivot_wider(df; names_from = [:cname1, :cname2], values_from = [:val1, :val2])
```

```
3×11 DataFrame
 Row │ x      a      b      val1_c_e   val1_c_f   val1_d_e   val1_d_f   val
2_c ⋯
     │ Int64  Int64  Int64  String?    String?    String?    String?    Str
ing ⋯
─────┼─────────────────────────────────────────────────────────────────────
─────
   1 │     1      4      7  ce_val1_1  cf_val1_1  de_val1_1  df_val1_1  ce_
val ⋯
   2 │     2      5      8  ce_val1_2  cf_val1_2  de_val1_2  df_val1_2  ce_
val
   3 │     3      6      9  ce_val1_3  cf_val1_3  de_val1_3  df_val1_3  ce_
val
                                                               4 columns om
itted
```





</details>

#### `relocate` - for relocating columns

This is for relocating columns and implements a replica of [`dplyr::relocate`](https://dplyr.tidyverse.org/reference/relocate.html)

<details>

```
using DataFrames
using DataConvenience: @>
using TidyStanza: relocate, any_of, last_col

# df <- tibble(a = 1, b = 1, c = 1, d = "a", e = "a", f = "a")

df = DataFrame(a = 1, b = 1, c = 1, d = "a", e = "a", f = "a")
```

```
# df %>% relocate(f)
@> df relocate(:f)
```

```
# df %>% relocate(a, .after = c)
@> df relocate(:a, after = :c)
```

```
# df %>% relocate(f, .before = b)
@> df relocate(:f, before = :b)
```

```
# df %>% relocate(a, .after = last_col())
@> df relocate(:a, after = names(df)[end])
```

```
@> df relocate(:a, after = last_col())
```

```
middle_col() = df->names(df)[end ÷ 2]
@> df relocate(:a, after = middle_col())
```

```
using TidyStanza: where

# df %>% relocate(where(is.character))
isstring(x) = eltype(x) <: AbstractString

@> df relocate(where(isstring))
```


```
@> df relocate(where(x->eltype(x) <: AbstractString))
```


```
# df %>% relocate(where(is.numeric), .after = last_col())
isnumeric(x) = eltype(x) <: Number

@> df relocate(where(isnumeric), after = last_col())
```

```
# df %>% relocate(any_of(c("a", "e", "i", "o", "u")))
@> df relocate(intersect(["a", "e", "i", "o", "u"], names(df)))
```

```
@> df relocate(any_of(["a", "e", "i", "o", "u"]))
```

```
#df2 <- tibble(a = 1, b = "a", c = 1, d = "a")

df2 = DataFrame(a = 1, b = "a", c = 1, d = "a")
```

```
#df2 %>% relocate(where(is.numeric), .after = where(is.character))

@> df2 relocate(where(isnumeric), after = where(isstring))
```

```
#df2 %>% relocate(where(is.numeric), .before = where(is.character))
@> df2 relocate(where(isnumeric), before = where(isstring))
```

</details>


## Why Stanza?
The verse in tidyverse is referring to the universe, but "verse" is a [technical term in poetry](https://en.wikipedia.org/wiki/Verse_(poetry)), so is [stanza](https://en.wikipedia.org/wiki/Stanza).
