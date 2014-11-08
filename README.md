test_app
========

=================================================================
Paramètres proxy
=================================================================
-----------------------------------------------------------------
$ git config --global http.proxy http://kuzh.polytechnique.fr:8080
$ git config --global https.proxy http://kuzh.polytechnique.fr:8080

Pour les retirer (en dehors de l'X) :

$ git config --global --unset http.proxy
$ git config --global --unset https.proxy

Pour Rubygems / Bundle, à tenter :
$ export http_proxy=http://kuzh.polytechnique.fr:8080 // (sur mac)
-----------------------------------------------------------------

=================================================================
Pusher sur git
=================================================================
-----------------------------------------------------------------
- git add -A
- git commit -m "Message perso"
- git push
-----------------------------------------------------------------

1) Création application

- Créer repository git hub puis  "git clone url"
- rails new .
- rails g controller home index
- créer une route pour rediriger l'adresse localhost:3000 vers home
  root 'home#index'
- pusher sur git


2) API et BackOffice

- Configurer database dans config/database.yml
  development:
    adapter: sqlite3
    database: db/shows_tonight_development.sqlite3
    pool: 5
    timeout: 5000

- Création de la base de donnée:  $ rake db:create
- Création des scaffolds/models/controllers
  $ rails g scaffold Nom_du_scaffold name:string location:string
  capacity:integer price:integer image:string date:date
- Appliquer la migration de la db: $ rake db:migrate
- Créer des Shows/Cateogries directement sur le backoffice

- Ajouter du style en ajoutant le gem au Gemfile
  $ gem "twitter-bootstrap-rails"
  $ bundle install

- Installer les feuilles CSS de nos scaffold etc
  $ rails g bootstrap:layout application
  $ rails generate bootstrap:install static
  $ rails g bootstrap:themed Shows

- Vérifier fichiers JSON avec JSONView sur Google Chrome
- Pusher sur git


3) Finaliser API

- Génération d'un modèle seul, puis méthodes et routes
  $ rails g model Booking user_name:string number:integer show:references
  $ rake db:migrate

- Vérifier relations entre modèles dans fichier app/models/show.rb
  class Show < ActiveRecord::Base
    has_many :bookings
  end

- Et dans app/models/booking.rb
  class Booking < ActiveRecord::Base
    belongs_to :show
  end

- Ajouter méthode book dans le controller de show
  # On ajoute la méthode book dans la liste des méthodes où on set le show
  au début
  before_action :set_show, only: [:show, :edit, :update, :destroy, :book]

  # On saute une etape de securite si on appel BOOK en JSON
  skip_before_action :verify_authenticity_token, only: [:book]

  # POST /shows/1/book.json
  def book
    # On crée un nouvel objet booking à partir des paramètres reçus
    @booking = Booking.new(booking_params)
    # On précise que cet object Booking dépend du show concerné
    @booking.show = @show

    respond_to do |format|
      if @booking.save
        format.json
      else
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # On ajoute les paramètres qu'on va envoyer avec le booking
    def booking_params
      params.require(:booking).permit(:user_name, :seats)
    end

- Ajout de la vue et des routes
  Créer fichier "book.json.jbuilder" dans le dossier app/views/shows
  json.extract! @booking, :id, :user_name, :seats

- Vérifier routes  $ rake routes
- Ajouter route pour poster utliser la méthode book - dans config/routes.rb
  #Cela signifie que nous déclarons l'url /shows/1/book par exemple, et que           les requêtes qui arrivent sur cette url en POST serons traitées par la méthode book du controller shows
  post 'shows/:id/book' => 'shows#book'

- Vérifier routes  $ rake routes
- Tester POST JSON sur la méthode book
  $ curl 'http://localhost:3000/shows/1/book.json' -H 'Content-Type: application/json'  -d '{"booking": {"user_name": "Jean Pierre le Spectateur", "number": 3 } }'
#Qui devrait renvoyer par exemple
{"id":7,"user_name":"Jean Pierre le Spectateur","number":3}

4) Déployer sur Heroku

- Ajouter des lignes dans db/seed.rb pour initialiser la db

  Show.create(
    name: "Mon premier Show",
    venue: "Salle Pleyel",
    description: "Concert blabla",
    capacity: 500,
    price: 30,
    image: "http://www.sallepleyel.fr/img/visuel/diaporama/salle_concert_scene.jpg",
    date: "2014-10-30"
  )

- Executer avec la commande :   $ rake db:seed
- Se connecter à Heroku : $ heroku login
- Créer application Heroku: $ heroku apps:create nom_de_l_app
- Changer paramètres DB
  Dans Gemfile  
  ->  gem 'sqlite3', group: :development
  ->  group :production do
        gem 'pg'
        gem 'rails_12factor'
      end
- Installer gem:  $ bundle install ou bundle install --without production
- Supprimer la partie "production" du fichier database.yml
- Pusher sur heroku: $ git push heroku master
