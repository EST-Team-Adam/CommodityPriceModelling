library(yaml)
library(quantmod)
library(feather)

## Read metadata
metadata = yaml.load_file("../metadata.yml")
metadata$start_date = as.Date(metadata$start_date, format = "%Y-%m-%d")
metadata$end_date = as.Date(metadata$end_date, format = "%Y-%m-%d")

## define function to download basket of exchange rates
getExchangeRates = function(basket, from, to){
    n_currency = length(basket)
    currency_basket = vector(mode = "list", length = n_currency)

    for(i in 1:n_currency){
        if((to - from) < 500){
            currency_basket[[i]] =
                getFX(basket[i], from = from, to = to, auto.assign = FALSE)
        } else {
            split_dates = unique(c(seq(from - 1, to, by = 500), to))
            for(j in 1:(length(split_dates) - 1)){
                tmp = getFX(basket[i], from = split_dates[j] + 1,
                            to = split_dates[j + 1], auto.assign = FALSE)
                currency_basket[[i]] = rbind(currency_basket[[i]], tmp)
            }
        }
        print(paste0("Currency ", basket[i], " downloaded"))
    }
    data.frame(date = as.Date(from:to),
               Reduce(function(x, y) merge(x, y), x = currency_basket))
}

## Download exchange rates
exchange_rate.df =
    with(metadata,
         getExchangeRates(basket = exchange_rates,
                          from = start_date,
                          to = end_date)
         )

## Save the data
write_feather(exchange_rate.df, path = "exchange_rate.feather")
