# Create Admin User
AdminUser.find_or_create_by!(email: 'admin@pittura.com') do |admin|
  admin.password = 'BB_B.$252#78deF'
  admin.password_confirmation = 'BB_B.$252#78deF'
end
puts "AdminUser created with email: admin@pittura.com and password: BB_B.$252#78deF"

# Create a simple PDF file for license attachments
require 'tempfile'

def create_dummy_pdf
  pdf_content = "%PDF-1.4\n1 0 obj\n<<\n/Type /Catalog\n/Pages 2 0 R\n>>\nendobj\n2 0 obj\n<<\n/Type /Pages\n/Kids [3 0 R]\n/Count 1\n>>\nendobj\n3 0 obj\n<<\n/Type /Page\n/Parent 2 0 R\n/MediaBox [0 0 612 792]\n>>\nendobj\nxref\n0 4\n0000000000 65535 f \n0000000010 00000 n \n0000000079 00000 n \n0000000173 00000 n \ntrailer\n<<\n/Size 4\n/Root 1 0 R\n>>\nstartxref\n253\n%%EOF"
  
  temp_file = Tempfile.new(['license', '.pdf'])
  temp_file.write(pdf_content)
  temp_file.rewind
  temp_file
end

# Create Sample Buyers
buyers = [
  {
    email: 'buyer1@example.com',
    first_name: 'John',
    last_name: 'Smith',
    company_name: 'Tech Retailers Inc',
    address: '123 Main St, New York, NY 10001',
    license_number: 'LIC001',
    website: 'https://techretailers.com',
    country_code: '+1',
    phone_number: '5551234567',
    role: 'buyer',
    approval_status: 'approved'
  },
  {
    email: 'buyer2@example.com',
    first_name: 'Sarah',
    last_name: 'Johnson',
    company_name: 'Mobile World Ltd',
    address: '456 Oak Ave, Los Angeles, CA 90210',
    license_number: 'LIC002',
    website: 'https://mobileworld.com',
    country_code: '+1',
    phone_number: '5559876543',
    role: 'buyer',
    approval_status: 'approved'
  },
  {
    email: 'buyer3@example.com',
    first_name: 'Michael',
    last_name: 'Brown',
    company_name: 'Electronics Hub',
    address: '789 Pine St, Chicago, IL 60601',
    license_number: 'LIC003',
    website: 'https://electronicshub.com',
    country_code: '+1',
    phone_number: '5555551234',
    role: 'buyer',
    approval_status: 'pending'
  }
]

buyers.each do |buyer_attrs|
  user = User.find_by(email: buyer_attrs[:email])
  
  if user.nil?
    # Create new user
    user = User.new(
      email: buyer_attrs[:email],
      password: 'password123',
      password_confirmation: 'password123',
      first_name: buyer_attrs[:first_name],
      last_name: buyer_attrs[:last_name],
      company_name: buyer_attrs[:company_name],
      address: buyer_attrs[:address],
      license_number: buyer_attrs[:license_number],
      website: buyer_attrs[:website],
      country_code: buyer_attrs[:country_code],
      phone_number: buyer_attrs[:phone_number],
      role: buyer_attrs[:role],
      approval_status: buyer_attrs[:approval_status]
    )
    
    # Attach dummy license file
    dummy_pdf = create_dummy_pdf
    user.license.attach(
      io: dummy_pdf,
      filename: "license_#{buyer_attrs[:license_number]}.pdf",
      content_type: 'application/pdf'
    )
    
    user.save!
    dummy_pdf.close
    dummy_pdf.unlink
    
    # Create a cart for each buyer
    Cart.find_or_create_by!(buyer: user)
    
    puts "Buyer created: #{buyer_attrs[:email]} (#{buyer_attrs[:approval_status]})"
  else
    puts "Buyer already exists: #{buyer_attrs[:email]}"
  end
end

# Create Sample Sellers
sellers = [
  {
    email: 'seller1@example.com',
    first_name: 'David',
    last_name: 'Wilson',
    company_name: 'Premium Electronics Supply',
    address: '321 Business Blvd, Miami, FL 33101',
    license_number: 'SEL001',
    website: 'https://premiumelectronics.com',
    country_code: '+1',
    phone_number: '5551111111',
    role: 'seller',
    approval_status: 'approved'
  },
  {
    email: 'seller2@example.com',
    first_name: 'Emma',
    last_name: 'Davis',
    company_name: 'Global Phone Distributors',
    address: '654 Commerce Way, Seattle, WA 98101',
    license_number: 'SEL002',
    website: 'https://globalphone.com',
    country_code: '+1',
    phone_number: '5552222222',
    role: 'seller',
    approval_status: 'approved'
  },
  {
    email: 'seller3@example.com',
    first_name: 'Robert',
    last_name: 'Taylor',
    company_name: 'Mobile Wholesale Corp',
    address: '987 Industrial Dr, Atlanta, GA 30301',
    license_number: 'SEL003',
    website: 'https://mobilewholesale.com',
    country_code: '+1',
    phone_number: '5553333333',
    role: 'seller',
    approval_status: 'approved'
  },
  {
    email: 'seller4@example.com',
    first_name: 'Lisa',
    last_name: 'Anderson',
    company_name: 'Tech Suppliers Inc',
    address: '147 Warehouse St, Houston, TX 77001',
    license_number: 'SEL004',
    website: 'https://techsuppliers.com',
    country_code: '+1',
    phone_number: '5554444444',
    role: 'seller',
    approval_status: 'pending'
  }
]

sellers.each do |seller_attrs|
  user = User.find_by(email: seller_attrs[:email])
  
  if user
    puts "Seller already exists: #{seller_attrs[:email]}"
  else
    dummy_pdf = create_dummy_pdf
    begin
      user = User.new(
        email: seller_attrs[:email],
        password: 'password123',
        password_confirmation: 'password123',
        first_name: seller_attrs[:first_name],
        last_name: seller_attrs[:last_name],
        company_name: seller_attrs[:company_name],
        address: seller_attrs[:address],
        license_number: seller_attrs[:license_number],
        website: seller_attrs[:website],
        country_code: seller_attrs[:country_code],
        phone_number: seller_attrs[:phone_number],
        role: seller_attrs[:role],
        approval_status: seller_attrs[:approval_status]
      )
      
      # Attach dummy license file
      user.license.attach(
        io: dummy_pdf,
        filename: "license_#{seller_attrs[:license_number]}.pdf",
        content_type: 'application/pdf'
      )
      
      user.save!
      puts "Seller created: #{seller_attrs[:email]} (#{seller_attrs[:approval_status]})"
    ensure
      dummy_pdf.close if dummy_pdf && !dummy_pdf.closed?
    end
  end
end

puts "\n=== SEED DATA SUMMARY ==="
puts "Total Admin Users: #{AdminUser.count}"
puts "Total Buyers: #{User.where(role: 'buyer').count}"
puts "Total Sellers: #{User.where(role: 'seller').count}"
puts "Total Approved Users: #{User.where(approval_status: 'approved').count}"
puts "Total Pending Users: #{User.where(approval_status: 'pending').count}"
puts "\n=== LOGIN CREDENTIALS ==="
puts "Admin: admin@pittura.com / BB_B.$252#78deF"
puts "All regular users: password123"
