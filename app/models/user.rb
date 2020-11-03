class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password

  has_many :microposts
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  #課題  
  has_many :favorites
 # has_many :microposts, through: :favorites
  has_many :likes, through: :favorites, source: :micropost
  
 #Userをフォロー
  def follow(other_user)
    #自分自身ではないかを検証
    unless self == other_user
     #フォロー重複を防ぐ
     self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  #Userをアンフォロー
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  #既にフォローしているかどうか調べる
  def following?(other_user)
   self.followings.include?(other_user)
  end
  
  #following_idsはUser がフォローしているUserのidの配列を取得。
  #自分自身の self.id もデータ型を合わせるために [self.id] と配列に変換して追加
  #whereメソッドはテーブル内の条件に一致したレコードを配列の形で取得
  def feed_microposts
   Micropost.where(user_id: self.following_ids + [self.id])
  end
  
 #favoriteを追加する
  def addfavorite(micropost)
     self.favorites.find_or_create_by(micropost_id: micropost.id)
  end
 
  #favoriteを削除する
  def unfavorite(micropost)
    favorite = self.favorites.find_by(micropost_id: micropost.id)
    favorite.destroy if favorite
  end
  
  #既にお気に入り登録されているか調べる
  def likes?(other_micropost)
   self.likes.include?(other_micropost)
  end
end