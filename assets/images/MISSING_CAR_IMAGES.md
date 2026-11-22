# Missing vehicle imagery

28 of the 30 sample vehicles have no matching bundled image. Their `imageAssetPath` is null and the UI explicitly shows **Image unavailable** instead of a different vehicle. The following suggested filenames are not bundled or registered yet.

Only Aston Martin Vantage and Nissan Sentra reuse their existing illustrative, AI-generated model images. The hero remains the original black sports illustration. The six category tiles retain existing representative artwork; those thumbnails are not photos of the category inventory.

Provide licensed, model-matching images before replacing these null mappings in `lib/data/demo_inventory.dart` and registering assets in `pubspec.yaml`.

| Model | Category | Suggested asset filename |
|---|---|---|
| Toyota Corolla | Economy | cars/corolla.png |
| Hyundai Elantra | Economy | cars/elantra.png |
| Kia Cerato | Economy | cars/cerato.png |
| Honda Civic | Economy | cars/civic.png |
| Toyota RAV4 | SUV | cars/rav4.png |
| Hyundai Tucson | SUV | cars/tucson.png |
| Kia Sportage | SUV | cars/sportage.png |
| Nissan X-Trail | SUV | cars/x-trail.png |
| BMW X5 | SUV | cars/x5.png |
| Porsche 911 Carrera | Sports | cars/911.png |
| Ford Mustang GT | Sports | cars/mustang.png |
| Chevrolet Corvette C8 | Sports | cars/corvette.png |
| Toyota GR Supra | Sports | cars/supra.png |
| Toyota Sienna | Family | cars/sienna.png |
| Honda Odyssey | Family | cars/odyssey.png |
| Kia Carnival | Family | cars/carnival.png |
| Hyundai Santa Fe | Family | cars/santa-fe.png |
| Volkswagen Tiguan | Family | cars/tiguan.png |
| Mercedes-Benz S-Class | Luxury | cars/s-class.png |
| BMW 7 Series | Luxury | cars/7-series.png |
| Audi A8 | Luxury | cars/a8.png |
| Lexus LS 500 | Luxury | cars/ls500.png |
| Porsche Panamera | Luxury | cars/panamera.png |
| Tesla Model 3 | Electric | cars/model3.png |
| Tesla Model Y | Electric | cars/modely.png |
| Hyundai IONIQ 5 | Electric | cars/ioniq5.png |
| Kia EV6 | Electric | cars/ev6.png |
| BMW i4 | Electric | cars/i4.png |
