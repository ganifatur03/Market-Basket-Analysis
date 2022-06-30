library(arules)
library(arulesViz)
library(ggplot2)
library(grid)
library(lubridate)
library(tidyverse)

retail_online <- read.csv("C:/Users/LENOVO/Documents/Course Online Python, SQL, R/Datasets/online_retail_II.csv", sep = ";")

head(retail_online)
data_retail <- read.transactions(file = "C:/Users/LENOVO/Documents/Course Online Python, SQL, R/Datasets/online_retail_II.csv", format="single", sep=";", cols = c(1,2), skip = 1)

data_retail
summary(data_retail)

#membuat visualisasi produk yang berada dalam transaksi
#Absolute berarti menampilkan data dalam bentuk jumlah produk dari total transaksi
itemFrequencyPlot(data_retail, topN=10, col="darkseagreen4", type="absolute", ylab="Frekuensi (absolut)", main="Frekuensi Penjualan Barang")

#Relative berarti menampilkan data berdasar jumlah produk dibandingkan dengan total transaksi
itemFrequencyPlot(data_retail, topN=10, col="deepskyblue", type="relative", ylab="Frekuensi (relatif)", main="Frekuensi Penjualan Barang")


#Visualisasi transaksi per bulan
retail_online %>%
  mutate(Month=as.factor(month(InvoiceDate))) %>%
  group_by(Month) %>%
  summarise(Invoice=n_distinct(Invoice)) %>%
  ggplot(aes(x=Month, y=Invoice)) +
  geom_bar(stat = "identity", fill="darkseagreen4", show.legend = FALSE) +
  geom_label(aes(label=Invoice)) +
  labs(title = "Transaksi tiap bulan") +
  theme_bw()

# Nilai untuk Support and confidence
supportLevels <- c(0.1, 0.05, 0.01, 0.005)
confidenceLevels <- c(0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1)

# Membuat variabel Kosong 
rules_sp10 <- NULL
rules_sp5 <- NULL
rules_sp1 <- NULL
rules_sp0.5 <- NULL

# Membuat algoritma Apriori dengan tingkat support 10%
for (i in 1:length(confidenceLevels)) {
  rules_sp10[i] <- length(apriori(data_retail, parameter=list(sup=supportLevels[1], 
                   conf=confidenceLevels[i], target="rules")))
}

# Membuat algoritma Apriori dengan tingkat support 5%
for (i in 1:length(confidenceLevels)){
  rules_sp5[i] <- length(apriori(data_retail, parameter=list(sup=supportLevels[2], 
                  conf=confidenceLevels[i], target="rules")))
}

# Membuat algoritma Apriori dengan tingkat support 1%
for (i in 1:length(confidenceLevels)){
  rules_sp1[i] <- length(apriori(data_retail, parameter=list(sup=supportLevels[3], 
                  conf=confidenceLevels[i], target="rules")))
}

# Membuat algoritma Apriori dengan tingkat support 0.5%
for (i in 1:length(confidenceLevels)){
  rules_sp0.5[i] <- length(apriori(data_retail, parameter=list(sup=supportLevels[4], 
                    conf=confidenceLevels[i], target="rules")))
}

# Setelah mendapat variabel berisi rules dari tingkat support berbeda, selanjutnya tahap pemilihan tingkat support dan confidence
# Data frame
num_rules <- data.frame(rules_sp10, rules_sp5, rules_sp1, rules_sp0.5, confidenceLevels)

# Menampilkan jumlah rules yang muncul dari tingkat support 10%, 5%, 1% dan 0.5%
ggplot(data=num_rules, aes(x=confidenceLevels)) +
  
  # Plot line dan points (support 10%)
  geom_line(aes(y=rules_sp10, colour="Support level of 10%")) + 
  geom_point(aes(y=rules_sp10, colour="Support level of 10%")) +
  
  # Plot line dan points (support 5%)
  geom_line(aes(y=rules_sp5, colour="Support level of 5%")) +
  geom_point(aes(y=rules_sp5, colour="Support level of 5%")) +
  
  # Plot line dan points (support 1%)
  geom_line(aes(y=rules_sp1, colour="Support level of 1%")) + 
  geom_point(aes(y=rules_sp1, colour="Support level of 1%")) +
  
  # Plot line dan points (support 0.5%)
  geom_line(aes(y=rules_sp0.5, colour="Support level of 0.5%")) +
  geom_point(aes(y=rules_sp0.5, colour="Support level of 0.5%")) +
  
  # Labs and theme
  labs(x="Confidence levels", y="Number of rules found", 
       title="Apriori algorithm with different support levels") +
  theme_bw() +
  theme(legend.title=element_blank())

# Memilih mana tingkat yang cocok untuk dipakai. Jika Rules yang muncul dari kombinasi support dan confidence terlalu besar maka data akan terlalu banyak untuk diproses
# Sementara jika rules terlalu sedikit maka juga tidak memungkinkan untuk dipilih
# Memilih algoritma Apriori dengan tingkat support 1% dan confidence 70%
Apriori_data <- apriori(data_retail, parameter=list(sup=supportLevels[3], conf=0.7, target="rules"))
inspect(Apriori_data)

# Memvisualisasikan hubungan tiap item dengan Scatter Plot dan Graph
# Scatter plot
plot(Apriori_data, measure=c("support", "lift"), shading="confidence")

# Graph (default layout)
plot(Apriori_data, method="graph")
