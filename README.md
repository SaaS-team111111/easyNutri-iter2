# EasyNutri

### Members:
- Zhengda Li - zl3651
- Qianyi Fan - qf2189
- Zian Zhang - zz3402
- Ying Wang - yw4360

## Here is Our Prototype!!

Heroku Link: https://easynutri-group5-6c340379424a.herokuapp.com/
##

### Install and Running/Testing

require:
- Ruby 3.2.2
- Rails 7.1.5+
- PostgreSQL 9.3+


### Clone project
```bash
git clone <repository-url>
cd easyNutri-iter1
```

### install dependencies
```bash
bundle install
```

### Install PostgreSQL
Ubuntu/Debian
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```
macOS (using Homebrew)
```bash
brew install postgresql@14
brew services start postgresql@14
```
macOS (using MacPorts)
```bash
sudo port install postgresql14-server
sudo port load postgresql14-server
```

### Setup database
```bash
# Create databases
rails db:create
# Run migrations
rails db:migrate
# Load sample food data (required for testing)
rails db:seed
```

Verify installation:
```bash
psql --version
```

### Run app
```bash
bundle exec rails s -b 0.0.0.0
```
`http://localhost:3000`


### Run rspec and cucumber tests

**Important:** Make sure database is set up first (see Setup database section above)

```bash
bundle exec rspec
bundle exec cucumber
```

**If you get "Migrations are pending" error:**
```bash
rails db:migrate
```
Our Testing result:
![](./image.png)


## Only if something went wrong

### configue database
Create `.env` file from template:
```bash
cp env.example .env
```

**Note:** Username and password are optional. If your PostgreSQL uses peer authentication (default on Linux/macOS), you don't need to set them. Only configure if your PostgreSQL requires password authentication:

Edit `.env` if needed:
```
DATABASE_USERNAME=postgres  # Optional: only if needed
DATABASE_PASSWORD=          # Optional: leave empty if using peer auth
DATABASE_HOST=localhost
DATABASE_PORT=5432
```

