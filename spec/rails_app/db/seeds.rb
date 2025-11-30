# frozen_string_literal: true

# Seed data for BetterPage testing

puts "Creating sample products..."

products = [
  {
    name: "MacBook Pro 16\"",
    description: "Apple MacBook Pro with M3 Max chip, 36GB RAM, 1TB SSD. Perfect for developers and creative professionals.",
    price: 3499.00,
    stock: 15,
    active: true
  },
  {
    name: "iPhone 15 Pro",
    description: "Latest iPhone with A17 Pro chip, 256GB storage, titanium design.",
    price: 999.00,
    stock: 50,
    active: true
  },
  {
    name: "AirPods Pro",
    description: "Active noise cancellation, spatial audio, MagSafe charging case.",
    price: 249.00,
    stock: 100,
    active: true
  },
  {
    name: "iPad Air",
    description: "10.9-inch Liquid Retina display, M1 chip, 64GB storage.",
    price: 599.00,
    stock: 30,
    active: true
  },
  {
    name: "Apple Watch Series 9",
    description: "Advanced health features, always-on display, GPS + Cellular.",
    price: 429.00,
    stock: 25,
    active: true
  },
  {
    name: "Magic Keyboard",
    description: "Full-size keyboard with Touch ID and numeric keypad.",
    price: 199.00,
    stock: 0,
    active: false
  },
  {
    name: "Studio Display",
    description: "27-inch 5K Retina display with 12MP camera and spatial audio.",
    price: 1599.00,
    stock: 8,
    active: true
  },
  {
    name: "Mac Mini",
    description: "Compact desktop with M2 chip, 8GB RAM, 256GB SSD.",
    price: 599.00,
    stock: 20,
    active: true
  }
]

products.each do |attrs|
  Product.find_or_create_by!(name: attrs[:name]) do |product|
    product.description = attrs[:description]
    product.price = attrs[:price]
    product.stock = attrs[:stock]
    product.active = attrs[:active]
  end
end

puts "Created #{Product.count} products!"
