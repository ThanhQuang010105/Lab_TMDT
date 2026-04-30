# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Spree::Core::Engine.load_seed if defined?(Spree::Core)
Spree::Auth::Engine.load_seed if defined?(Spree::Auth)

# === Tạo Danh mục sản phẩm ===
store = Spree::Store.default || Spree::Store.first
taxonomy = Spree::Taxonomy.find_or_create_by!(name: 'Phụ kiện xe hơi', store: store)
root_taxon = taxonomy.root

categories = [
  'Lốp xe & Mâm',
  'Đèn xe',
  'Camera hành trình',
  'Phụ kiện nội thất',
  'Dầu nhớt & Bảo dưỡng'
]

taxons = {}
categories.each do |cat_name|
  taxons[cat_name] = root_taxon.children.find_or_create_by!(name: cat_name, taxonomy: taxonomy)
end

# === Tạo Sản phẩm mẫu ===
default_shipping_category = Spree::ShippingCategory.find_or_create_by!(name: 'Default')

products_data = [
  { name: 'Camera hành trình Vietmap', price: 1500000, category: 'Camera hành trình' },
  { name: 'Đèn LED xe hơi', price: 800000, category: 'Đèn xe' },
  { name: 'Lốp Michelin 205/55R16', price: 2200000, category: 'Lốp xe & Mâm' },
  { name: 'Thảm lót sàn 5D', price: 1200000, category: 'Phụ kiện nội thất' },
  { name: 'Dầu nhớt Castrol 5W-40', price: 350000, category: 'Dầu nhớt & Bảo dưỡng' }
]

products_data.each do |pd|
  product = Spree::Product.find_or_create_by!(name: pd[:name]) do |p|
    p.price = pd[:price]
    p.shipping_category = default_shipping_category
    p.sku = "SKU-#{pd[:name].parameterize.upcase}"
    p.available_on = Time.current
    p.stores << store
  end
  
  # Thêm vào danh mục
  taxon = taxons[pd[:category]]
  unless product.taxons.include?(taxon)
    product.taxons << taxon
  end
end

puts "Seed dữ liệu thành công!"
