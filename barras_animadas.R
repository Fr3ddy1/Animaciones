#CARGO LIBRERIAS
library(tidyverse)
library(gganimate)
library(av)

#CARGO DATA A USAR
gdp_tidy <- read_csv("./data/gdp_tidy.csv")

#PROCESO DATA
gdp_formatted <- gdp_tidy %>%
  group_by(year) %>%
  # The * 1 makes it possible to have non-integer ranks while sliding
  mutate(rank = rank(-value),
         Value_rel = value/value[rank==1],
         Value_lbl = paste0(" ",round(value/1e9))) %>%
  group_by(country_name) %>% 
  filter(rank <=10) %>%
  ungroup()

#CREO ANIMACION
anim <- ggplot(gdp_formatted, aes(rank, group = country_name, 
                fill = as.factor(country_name), color = as.factor(country_name))) +
  geom_tile(aes(y = value/2,
                height = value,
                width = 0.9), alpha = 0.8, color = NA) +
  geom_text(aes(y = 0, label = paste(country_name, " ")), vjust = 0.2, hjust = 1) +
  geom_text(aes(y=value,label = Value_lbl, hjust=0)) +
  coord_flip(clip = "off", expand = FALSE) +
  scale_y_continuous(labels = scales::comma) +
  scale_x_reverse() +
  guides(color = FALSE, fill = FALSE) +
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
         axis.title.y=element_blank(),
        legend.position="none",
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        panel.grid.major.x = element_line( size=.1, color="grey" ),
        panel.grid.minor.x = element_line( size=.1, color="grey" ),
        plot.title=element_text(size=25, hjust=0.5, face="bold", colour="grey", vjust=-1),
        plot.subtitle=element_text(size=18, hjust=0.5, face="italic", color="grey"),
        plot.caption =element_text(size=8, hjust=0.5, face="italic", color="grey"),
        plot.background=element_blank(),
       plot.margin = margin(2,2, 2, 4, "cm")) +
  transition_states(year, transition_length = 4, state_length = 1) +
  view_follow(fixed_x = TRUE)  +
  labs(title = 'GDP per Year : {closest_state}',  
       subtitle  =  "Top 10 Countries",
       caption  = "GDP in Billions USD | Data Source: World Bank Data") 

#EXPORTO GIF
animate(anim, 100, fps = 20,  width = 1200, height = 1000, 
        renderer = gifski_renderer("gganim.gif")) 

#EXPORTO A VIDEO CON FORMATO MP4
for_mp4 <- animate(anim, 200, fps = 20,  width = 1200, height = 1000)

#animate(anim, 100, fps = 20,duration = 30, width = 1200, height = 1000,
#        renderer=ffmpeg_renderer())

# Video output
a <- animate(
  anim + enter_fade() + exit_fly(y_loc = 1),
  renderer = av_renderer()
)

#GUARDO VIDEO
anim_save("animation.mp4", animation = a )
