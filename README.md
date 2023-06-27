# Final Term Project of CENG469 2022-2023 - Scene Generation with an HDR Envmap, Image Based Lighting and Shadows

You can run this project after cloning it using:

```
cd proj
make && ./main
```

![shanghaishadow](https://github.com/ilkerkosaroglu/graphicsfinal/assets/31799528/04a8d71d-71cd-4f8c-a83a-898265bf2b21)


We have some controls enables, here's a list of them:

| Key/s  | Action |
| ------------- | ------------- |
| WASD  | Movement  |
| Mouse  | Pan  |
| Scroll  | Zoom  |

| Key/s  | Action |
| ------------- | ------------- |
| QE  | Change scene (3 Scenes available, italy, village, shanghai)  |
| RF  | Change materials between white marble and rusted metal  |


| GHJKVB  | Change render mode: |
| ------------- | ------------- |
| G  | Usual rendering  |
| H  | Animated specular map, aka PBR prefilter map  |
| J  | Diffuse map, aka PBR diffuse irradiance  |

| Key/s  | Action |
| ------------- | ------------- |
| Z  | Toggle between static / moving shadows |


(Keys just for testing/debug: )
<details>

  
| GHJKVB  | Change render mode: |
| ------------- | ------------- |
| K  | (ambient)  |
| V  | (only predefined lights to measure PBR response)  |
| B  | (ambient + predefined lights)  |

| Key/s  | Action |
| ------------- | ------------- |
| XC  | Change hemisphere radius  |

</details>
