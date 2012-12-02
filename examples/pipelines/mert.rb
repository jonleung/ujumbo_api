product = Product.new
product.name = "Mert Scheduling App"

product.users.sync("users", GoogleDoc.new({name: Name, email: Email, phone: Phone}))
product.contexts.sync("GoogleDoc.new())

pipeline = product.pipelines.new
pipeline = 