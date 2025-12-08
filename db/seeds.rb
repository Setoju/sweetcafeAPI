# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data (only in development)
if Rails.env.development?
  puts "Clearing existing data..."
  Delivery.destroy_all
  OrderItem.destroy_all
  Order.destroy_all
  MenuItem.destroy_all
  Category.destroy_all
  User.destroy_all
end

puts "Seeding database..."

# Create Users
puts "Creating users..."
admin = User.create!(
  name: "Admin User",
  email: "admin@sweetcafe.com",
  phone: "1234567890",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: "admin"
)

customer1 = User.create!(
  name: "John Doe",
  email: "john@example.com",
  phone: "5551234567",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: "customer"
)

customer2 = User.create!(
  name: "Jane Smith",
  email: "jane@example.com",
  phone: "5559876543",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: "customer"
)

puts "Created #{User.count} users"

# Create Categories
puts "Creating categories..."
drinks = Category.create!(
  name: "Drinks",
  description: "Hot and cold beverages"
)

ice_creams = Category.create!(
  name: "Ice Creams",
  description: "Delicious ice cream sundaes and treats"
)

donuts = Category.create!(
  name: "Donuts",
  description: "Fresh glazed donuts with various toppings"
)

cakes = Category.create!(
  name: "Cakes",
  description: "Delightful cakes and pastries"
)

cupcakes = Category.create!(
  name: "Cupcakes",
  description: "Sweet cupcakes with creative flavors"
)

puts "Created #{Category.count} categories"

# Create Menu Items
puts "Creating menu items..."

# Drinks
MenuItem.create!([
  { name: "Classic Layered Latte", price: 3.75, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/classic-layered-latte.webp", description: "A perfectly layered latte with distinct strata of milk, espresso, and foam, topped with a dusting of cinnamon." },
  { name: "Creamy Cafe Latte", price: 3.50, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/creamy-cafe-latte.webp", description: "A smooth and creamy cafe latte, richly textured with a generous swirl of whipped cream and a sprinkle of cocoa powder." },
  { name: "Three-Tiered Macchiato", price: 4.00, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/three-tiered-macchiato.webp", description: "An elegantly layered macchiato showcasing clear divisions of milk, rich espresso, and velvety foam, finished with a hint of cinnamon." },
  { name: "Chocolate Decadence Drink", price: 4.25, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/chocolate-decadence-drink.webp", description: "An indulgent chocolate drink with rich chocolate syrup streaking the glass, topped with whipped cream, chocolate shavings, and cocoa powder." },
  { name: "Dark Chocolate Frappe", price: 4.10, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/dark-chocolate-frappe.webp", description: "A deep, rich dark chocolate frappe with a cool, creamy texture, finished with whipped cream and a dusting of cocoa." },
  { name: "Toasted Marshmallow Latte", price: 4.50, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/toasted-marshmallow-latte.webp", description: "A cozy latte crowned with a heap of perfectly toasted mini marshmallows, offering a sweet, smoky aroma." },
  { name: "Caramel Swirl Delight", price: 4.20, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/caramel-swirl-delight.webp", description: "A beautifully layered coffee drink with generous swirls of caramel cascading down the sides, topped with whipped cream and caramel drizzle." },
  { name: "Simple Caramel Drizzle", price: 3.90, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/simple-caramel-drizzle.webp", description: "A comforting coffee drink with a base of milk and coffee, generously topped with whipped cream and a classic caramel drizzle." },
  { name: "Extra Caramel Indulgence", price: 4.30, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/extra-caramel-indulgence.webp", description: "An ultimate caramel experience, featuring thick caramel drizzles inside and on top of a rich coffee base with whipped cream." },
  { name: "Minimalist Mocha", price: 3.80, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/minimalist-mocha.webp", description: "A sleek and sophisticated mocha, with just a hint of chocolate and a perfect dollop of whipped cream on top." },
  { name: "Caramel Macchiato Twist", price: 4.15, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/caramel-macchiato-twist.webp", description: "A beautifully layered drink with espresso and milk, topped with thick foam, caramel drizzle, and a dusting of cocoa powder." },
  { name: "Dark Mocha Float", price: 4.30, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/dark-mocha-float.webp", description: "A deep, rich dark coffee base layered with milk, crowned with a large scoop of sweet foam and a generous dusting of cocoa." },
  { name: "Chocolate Chip Frappe", price: 4.75, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/chocolate-chip-frappe.webp", description: "A vanilla-based frappe or milkshake infused with crushed dark chocolate cookies/chips, topped with whipped cream and chocolate pieces." },
  { name: "Hazelnut Latte", price: 3.65, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/hazelnut-latte.webp", description: "A comforting blend of coffee and milk, topped with a swirl of whipped cream and a sprinkle of cinnamon or hazelnut powder." },
  { name: "Whipped Milk Shake", price: 3.50, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/whipped-milk-shake.webp", description: "A creamy and smooth vanilla or white chocolate milkshake, simply topped with a perfect swirl of plain whipped cream." },
  { name: "Triple Chocolate Layer", price: 4.95, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/triple-chocolate-layer.webp", description: "An ultra-decadent drink with rich layers of coffee and chocolate milk, topped with whipped cream, chocolate shavings, and dark chocolate squares." },
  { name: "Simple Sweet Milk", price: 3.25, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/simple-sweet-milk.webp", description: "A classic sweet coffee drink, elegantly layered with milk, espresso, and foam, perfect for a subtle caramel flavor." },
  { name: "Espresso Cream Fusion", price: 4.40, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/espresso-cream-fusion.webp", description: "A visually stunning layered drink with a sharp espresso shot melting into cold milk, topped with whipped cream." },
  { name: "Mocha Dream Whip", price: 4.55, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/mocha-dream-whip.webp", description: "A rich, chocolate-flavored coffee drink, fully blended and topped with a generous serving of whipped cream and cocoa dust." },
  { name: "Layered Cream Coffee", price: 3.80, category: drinks, available: true, size: 400, image_url: "https://sweetcafeapi.onrender.com/images/drinks/layered-cream-coffee.webp", description: "A classic layered coffee drink with milk, coffee, and a thick layer of whipped cream, drizzled with caramel sauce." }
])

# Ice Creams
MenuItem.create!([
  { name: "Cherry Hot Fudge Sundae", price: 5.50, category: ice_creams, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/ice-creams/cherry-hot-fudge-sundae.webp", description: "A classic vanilla sundae featuring hot fudge sauce, whipped cream, and crowned with two bright red maraschino cherries." },
  { name: "Forest Berry Swirl", price: 6.25, category: ice_creams, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/ice-creams/forest-berry-swirl.webp", description: "A rich vanilla ice cream layered with cookies, topped with whipped cream, dark berry sauce, fresh raspberries, and blackberries." },
  { name: "Raspberry Brownie Bomb", price: 5.75, category: ice_creams, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/ice-creams/raspberry-brownie-bomb.webp", description: "Vanilla ice cream layered with brownie chunks, drenched in chocolate sauce, topped with whipped cream and fresh raspberries." },
  { name: "Caramel Drizzle Dream", price: 5.20, category: ice_creams, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/ice-creams/caramel-drizzle-dream.webp", description: "A large serving of vanilla ice cream with generous swirls of smooth caramel syrup dripping down the glass." },
  { name: "Salted Caramel Scoop", price: 5.80, category: ice_creams, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/ice-creams/salted-caramel-scoop.webp", description: "Three scoops of creamy, rich caramel ice cream, lightly drizzled with caramel sauce for an intense, savory-sweet flavour." },
  { name: "Mocha Cookie Crunch", price: 6.50, category: ice_creams, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/ice-creams/mocha-cookie-crunch.webp", description: "Vanilla and coffee ice cream, layered with cookie pieces, drizzled with chocolate sauce, and topped with crunchy chunks." },
  { name: "Chocolate Hazelnut Heaven", price: 5.99, category: ice_creams, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/ice-creams/chocolate-hazelnut-heaven.webp", description: "Rich chocolate ice cream topped with chocolate drizzle, hazelnut pieces, and dark chocolate shavings." },
  { name: "Cookies and Cream Delight", price: 5.45, category: ice_creams, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/ice-creams/cookies-and-cream-delight.webp", description: "Classic vanilla ice cream generously mixed with dark chocolate cookie chunks, served in a tall glass." },
  { name: "Strawberry Cheesecake", price: 6.10, category: ice_creams, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/ice-creams/strawberry-cheesecake.webp", description: "Strawberry ice cream layered with syrup, topped with whipped cream, nut crumble, and fresh, ripe strawberry halves." },
  { name: "Mint Chocolate Chip Sundae", price: 5.65, category: ice_creams, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/ice-creams/mint-chocolate-chip-sundae.webp", description: "Mint-flavored ice cream marbled with chocolate syrup, topped with whipped cream, chocolate chips, and fresh mint leaves." },
  { name: "Pistachio Dream Float", price: 6.30, category: ice_creams, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/ice-creams/pistachio-dream-float.webp", description: "A rich, creamy dessert featuring a pistachio milkshake base, topped with white ice cream/whipped cream and generously sprinkled with chopped pistachios." },
  { name: "Mixed Berry Crumble Sundae", price: 6.55, category: ice_creams, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/ice-creams/mixed-berry-crumble-sundae.webp", description: "Vanilla ice cream layered with berry jam and biscuit crumble, topped with fresh raspberries, strawberries, whipped cream, and chocolate sauce." },
  { name: "Tropical Strawberry Split", price: 5.90, category: ice_creams, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/ice-creams/tropical-strawberry-split.webp", description: "Vanilla ice cream layered with fruit, syrup, and topped with whipped cream, hot fudge, and fresh strawberries and banana slices." }
])

# Donuts
MenuItem.create!([
  { name: "Strawberry Mallow", price: 2.99, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/strawberry-mallow.webp", description: "A classic soft donut covered in a bright pink strawberry glaze and decorated with delicate stripes of white vanilla drizzle." },
  { name: "Chocolate Truffle Crunch", price: 3.25, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/chocolate-truffle-crunch.webp", description: "A rich chocolate donut featuring a thick layer of glossy dark glaze, generously coated with crispy chocolate and crimson-red sprinkles." },
  { name: "Tropical Coconut Dream", price: 2.75, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/tropical-coconut-dream.webp", description: "A vanilla-glazed donut completely covered in fluffy white coconut shavings and hints of lightly toasted flakes for a tropical flavor." },
  { name: "Pistachio Matcha Delight", price: 3.49, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/pistachio-matcha-delight.webp", description: "An original donut with a vibrant lime-green glaze, offering a subtle blend of pistachio and matcha flavor, topped with chopped pistachios." },
  { name: "Strawberry Pistachio Fusion", price: 3.75, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/strawberry-pistachio-fusion.webp", description: "An elegant donut with a light pink glaze, adorned with fresh strawberry slices and a crunchy topping of finely crushed pistachios." },
  { name: "Halloween Spider Web", price: 3.99, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/halloween-spider-web.webp", description: "A festive, dark chocolate-glazed donut decorated with a white spiderweb pattern, orange drizzles, and classic yellow/white Candy Corn pieces." },
  { name: "Double Choco Zebra", price: 3.15, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/double-choco-zebra.webp", description: "A striped donut with a white vanilla glaze base and dark chocolate drizzle, finished with a generous layer of mini chocolate crispies." },
  { name: "Glamour Sparkle", price: 3.50, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/glamour-sparkle.webp", description: "An elegant donut featuring a glossy dark chocolate glaze, decorated with a glamorous sprinkle mix of pink, white, and golden sugar pearls." },
  { name: "Strawberry Fountain", price: 3.60, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/strawberry-fountain.webp", description: "A sweet donut with a bubblegum-pink glaze, beautifully garnished with slices of fresh strawberries and multi-colored, shiny sprinkles." },
  { name: "Autumn Ghost Swirl", price: 3.10, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/autumn-ghost-swirl.webp", description: "A donut with a bright white vanilla glaze, contrasted by orange and dark chocolate drizzles, and topped with autumn-themed sprinkles." },
  { name: "Sea Salt Caramel", price: 3.55, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/sea-salt-caramel.webp", description: "A decadent donut with a smooth, glossy caramel glaze, drizzled with extra caramel and sprinkled with crunchy sea salt flakes." },
  { name: "Rainbow Explosion", price: 3.99, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/rainbow-explosion.webp", description: "An eye-catching donut with a vibrant rainbow-colored glaze, topped with white frosting stripes and a generous mix of multi-colored sprinkles." },
  { name: "White Chocolate Raspberry", price: 4.15, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/white-chocolate-raspberry.webp", description: "A luxurious donut covered in creamy white chocolate glaze, elegantly decorated with fresh raspberries and pieces of raspberry preserve." },
  { name: "Purple Passion", price: 2.89, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/purple-passion.webp", description: "A simple yet bold donut featuring a smooth, rich purple glaze (like blueberry or lavender) and covered entirely in colorful candy sprinkles." },
  { name: "Cosmic Blue Pecan", price: 4.50, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/cosmic-blue-pecan.webp", description: "An exotic donut with a glittering, swirling blue glaze, reminiscent of a galaxy, and scattered with crunchy chopped pecans or walnuts." },
  { name: "Salted Butterscotch", price: 3.35, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/salted-butterscotch.webp", description: "A gourmet donut with a deeply rich, golden butterscotch glaze, finished with large flakes of decorative coarse sea salt." },
  { name: "Lemon Sparkle", price: 2.99, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/lemon-sparkle.webp", description: "A zesty donut with a bright, sunny lemon-yellow glaze, finished with a mix of small, elegant gold and white sugar pearls." },
  { name: "Cherry Glaze Swirl", price: 2.75, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/cherry-glaze-swirl.webp", description: "A simple, shiny donut with a vibrant cherry-red glaze, decorated with thick, flowing white vanilla cream stripes." },
  { name: "White Chocolate Toffee", price: 3.15, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/white-chocolate-toffee.webp", description: "A classic white vanilla-glazed donut, contrasted with dark chocolate drizzles and topped with crunchy, golden toffee bits." },
  { name: "Cookies and Cream", price: 3.85, category: donuts, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/donuts/cookies-and-cream.webp", description: "A sweet donut with a smooth white glaze, dark chocolate drizzles, and crushed dark chocolate sandwich cookies for a 'Cookies & Cream' effect." }
])

# Cakes
MenuItem.create!([
  { name: "Classic Fudge Brownie", price: 4.50, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/classic-fudge-brownie.webp", description: "A rich, dense chocolate brownie with a desirable crackled top and a perfectly chewy interior." },
  { name: "Chocolate Drizzle Brownie", price: 4.75, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/chocolate-drizzle-brownie.webp", description: "A soft, fudgy brownie square enhanced with elegant diagonal dark chocolate drizzles on top." },
  { name: "Caramel Swirl Brownie", price: 4.90, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/caramel-swirl-brownie.webp", description: "A decadent chocolate brownie square generously topped with a thick layer of golden, sweet caramel sauce." },
  { name: "Cheesecake Swirl Brownie", price: 5.15, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/cheesecake-swirl-brownie.webp", description: "A delightful hybrid of fudgy brownie base and creamy cheesecake topping, finished with chocolate chips and drizzle." },
  { name: "Spiced Carrot Cake Slice", price: 5.50, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/spiced-carrot-cake-slice.webp", description: "A moist and flavorful spiced cake with a double layer of rich cream cheese frosting." },
  { name: "Blueberry Vanilla Cake Slice", price: 5.75, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/blueberry-vanilla-cake-slice.webp", description: "A square slice of light vanilla sponge cake with white cream filling, beautifully topped with a layer of fresh blueberries." },
  { name: "Tropical Mousse Bar", price: 4.80, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/tropical-mousse-bar.webp", description: "A refreshing layered dessert bar with a sponge base, white cream layer, and a top layer of pink/red fruit mousse." },
  { name: "Classic Napoleon Slice", price: 5.90, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/classic-napoleon-slice.webp", description: "A delightful multilayered puff pastry slice with rich, creamy custard filling, dusted with pastry crumbs." },
  { name: "Peanut Butter Chocolate Bar", price: 5.25, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/peanut-butter-chocolate-bar.webp", description: "A dense and chewy dessert bar with a crunchy base, topped with coconut flakes, nuts, and large milk chocolate chips." },
  { name: "Golden Thread Cake", price: 5.60, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/golden-thread-cake.webp", description: "A light and airy square sponge cake topped with delicate, sweet golden threads (Foi Thong), a traditional Southeast Asian delicacy." },
  { name: "Cinnamon Streusel Coffee Cake", price: 5.75, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/cinnamon-streusel-coffee-cake.webp", description: "A moist coffee cake slice with a cinnamon filling and a crunchy, buttery streusel topping." },
  { name: "Brownie Ice Cream Sundae", price: 6.80, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/brownie-ice-cream-sundae.webp", description: "A warm, rich chocolate brownie topped with a scoop of vanilla ice cream, hot fudge sauce, whipped cream, and a cherry." },
  { name: "Mango Cream Cheesecake", price: 7.95, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/mango-cream-cheesecake.webp", description: "A tropical no-bake cheesecake slice layered with crust and cream, topped with fresh slices of mango." },
  { name: "Vanilla Mille-Feuille", price: 6.20, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/vanilla-mille-feuille.webp", description: "A classic French pastry with flaky puff pastry layers, thick vanilla custard cream, and a simple white glaze with chocolate stripes." },
  { name: "Chocolate Chip Scone", price: 4.50, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/chocolate-chip-scone.webp", description: "A dense, buttery scone baked with generous dark chocolate chips, perfect for dipping in coffee." },
  { name: "Classic Mocha Opera Slice", price: 7.70, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/classic-mocha-opera-slice.webp", description: "An elegant layer cake featuring coffee-flavored buttercream, chocolate ganache, and light sponge layers, topped with a smooth chocolate glaze." },
  { name: "Cherry Swirl Chocolate Bar", price: 6.50, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/cherry-swirl-chocolate-bar.webp", description: "A sponge cake bar with a creamy base, chocolate accents, and whole cherries nestled inside, finished with a dark chocolate topping." },
  { name: "Cookies and Cream Layer Cake", price: 7.25, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/cookies-and-cream-layer-cake.webp", description: "A no-bake layer cake made with alternating layers of dark chocolate wafers and sweet white cream, topped with cookie crumbles." },
  { name: "Tres Leches Cake", price: 6.90, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/tres-leches-cake.webp", description: "A light sponge cake soaked in three types of milk (tres leches), topped with whipped cream and a dusting of cinnamon." },
  { name: "Strawberry Shortcake Square", price: 6.70, category: cakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cakes/strawberry-shortcake-square.webp", description: "A perfect square of shortcake layered with sweet cream and fresh strawberry slices, crowned with a whole large berry." }
])

# Cupcakes
MenuItem.create!([
  { name: "Strawberry Dream", price: 3.50, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/strawberry-dream.webp", description: "A delicate vanilla cupcake topped with sweet pink strawberry buttercream and garnished with a glossy fresh strawberry." },
  { name: "Decadent Chocolate Swirl", price: 3.75, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/decadent-chocolate-swirl.webp", description: "A rich chocolate cupcake crowned with a tall swirl of velvety chocolate frosting and scattered with dark chocolate shavings." },
  { name: "Blueberry Delight", price: 3.60, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/blueberry-delight.webp", description: "A light vanilla cupcake topped with pastel purple blueberry buttercream and a generous pile of fresh, ripe blueberries." },
  { name: "Rainbow Magic", price: 4.15, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/rainbow-magic.webp", description: "A vanilla cupcake featuring a mesmerizing spiral of brightly colored rainbow buttercream, finished with tiny sugar sprinkles." },
  { name: "Electric Blue Velvet", price: 3.90, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/electric-blue-velvet.webp", description: "A dark chocolate cupcake paired with a striking swirl of bright blue frosting, lightly dusted with shimmering sugar crystals." },
  { name: "Red Velvet Classic", price: 3.85, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/red-velvet-classic.webp", description: "The iconic Red Velvet cupcake, topped with rich cream cheese frosting and sprinkled with crimson cake crumbs." },
  { name: "Cookies and Cream King", price: 4.20, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/cookies-and-cream-king.webp", description: "A dark chocolate cupcake with white vanilla buttercream, dark chocolate drizzle, and a whole chocolate sandwich cookie on top." },
  { name: "Cinnamon Spice Latte", price: 3.70, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/cinnamon-spice-latte.webp", description: "A vanilla or spice cupcake topped with coffee-flavored buttercream, dusted with cinnamon powder and adorned with a cinnamon stick." },
  { name: "Coconut Snow Cap", price: 3.55, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/coconut-snow-cap.webp", description: "A vanilla cupcake with a tall swirl of pure white vanilla frosting, generously covered in fluffy white coconut flakes." },
  { name: "Matcha Green Tea", price: 4.00, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/matcha-green-tea.webp", description: "A flavorful green tea cupcake topped with a vibrant green matcha-infused buttercream swirl." },
  { name: "Mocha Almond Fudge", price: 4.10, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/mocha-almond-fudge.webp", description: "A rich chocolate cupcake with coffee-flavored buttercream, decorated with chocolate pieces, coffee beans, and chocolate chips." },
  { name: "Galaxy Unicorn Swirl", price: 4.50, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/galaxy-unicorn-swirl.webp", description: "A vanilla cupcake topped with shimmering, marbled pink, blue, and purple frosting, sprinkled with edible glitter for a mystical effect." },
  { name: "Salted Toffee Caramel", price: 3.95, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/salted-toffee-caramel.webp", description: "A spiced or vanilla cupcake with a light caramel buttercream, generously coated with crunchy, buttery toffee bits." },
  { name: "Valentine's Heart", price: 4.00, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/valentine's-heart.webp", description: "A dark chocolate cupcake with soft pink frosting, topped with red and pink sprinkles and a decorative candy heart." },
  { name: "Lemon Meringue Cloud", price: 4.25, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/lemon-meringue-cloud.webp", description: "A lemon or vanilla cupcake topped with a tall swirl of glossy, toasted Italian meringue (marshmallow frosting)." },
  { name: "Choco-Almond Crunch", price: 4.30, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/choco-almond-crunch.webp", description: "A chocolate or coffee cupcake with a caramel/vanilla frosting, adorned with dark chocolate shards and slivered almonds." },
  { name: "Banana Split", price: 3.75, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/banana-split.webp", description: "A vanilla cupcake with bright yellow banana-flavored frosting, topped with a slice of fresh banana glazed with syrup." },
  { name: "Maraschino Cherry Kiss", price: 3.65, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/maraschino-cherry-kiss.webp", description: "A delicate pink-frosted cupcake, sprinkled with pink sugar and crowned with a vibrant red candied maraschino cherry." },
  { name: "Raspberry Jam Delight", price: 4.40, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/raspberry-jam-delight.webp", description: "A vanilla cupcake with a layer of tart raspberry jam under a pink swirl of frosting, garnished with fresh raspberries." },
  { name: "Autumn Spice Halloween", price: 4.20, category: cupcakes, available: true, size: 100, image_url: "https://sweetcafeapi.onrender.com/images/cupcakes/autumn-spice-halloween.webp", description: "A chocolate cupcake with white and bright orange frosting, heavily decorated with chocolate chips and colorful seasonal sprinkles." }
])

puts "Created #{MenuItem.count} menu items"

MenuItem.where(available_quantity: 0).find_each do |item|
  item.update!(available_quantity: rand(10..100))
end

# Create Sample Orders
puts "Creating sample orders..."

order1 = Order.create!(
  user: customer1,
  status: "pending",
  notes: "Deliver after 5 PM",
  total_amount: 0
)

order1_items = [
  { menu_item: MenuItem.find_by(name: "Classic Layered Latte"), quantity: 2 },
  { menu_item: MenuItem.find_by(name: "Strawberry Dream"), quantity: 1 },
  { menu_item: MenuItem.find_by(name: "Classic Fudge Brownie"), quantity: 1 }
]

total = 0
order1_items.each do |item_data|
  item = order1.order_items.create!(
    menu_item: item_data[:menu_item],
    total_quantity: item_data[:quantity],
    price: item_data[:menu_item].price,
    subtotal: item_data[:menu_item].price * item_data[:quantity]
  )
  total += item.subtotal
end
order1.update!(total_amount: total)

order1.create_delivery!(
  address: "123 Main Street",
  city: "New York",
  phone: "5551234567",
  delivery_notes: "Ring the doorbell",
  delivery_status: "pending"
)

order2 = Order.create!(
  user: customer2,
  status: "completed",
  notes: "Extra whipped cream",
  total_amount: 0
)

order2_items = [
  { menu_item: MenuItem.find_by(name: "Chocolate Chip Frappe"), quantity: 1 },
  { menu_item: MenuItem.find_by(name: "Strawberry Mallow"), quantity: 2 },
  { menu_item: MenuItem.find_by(name: "Cherry Hot Fudge Sundae"), quantity: 1 }
]

total = 0
order2_items.each do |item_data|
  item = order2.order_items.create!(
    menu_item: item_data[:menu_item],
    total_quantity: item_data[:quantity],
    price: item_data[:menu_item].price,
    subtotal: item_data[:menu_item].price * item_data[:quantity]
  )
  total += item.subtotal
end
order2.update!(total_amount: total)

puts "Created #{Order.count} orders"

puts "Seeding completed!"
puts "="*50
puts "Admin User: admin@sweetcafe.com / Password123!"
puts "Customer 1: john@example.com / Password123!"
puts "Customer 2: jane@example.com / Password123!"
puts "="*50
