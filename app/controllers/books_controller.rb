class BooksController < ApplicationController
  def index
    @books = Book.all
    @top_three = Book.top_three
    @bottom_three = Book.bottom_three
    @most_reviews = Review.most_reviews(3)
  end

  def show
    @book = Book.find(params[:id])
    @average_rating = @book.average_rating
    @top_reviews = @book.sorted_reviews(:desc, 3)
    @bottom_reviews = @book.sorted_reviews(:asc, 3)
  end

  def new
    @book = Book.new
  end

  def create
    book = Book.create(book_params)
    if book.save
      redirect_to book_path(book)
    else
      render :new
    end
  end

  def delete
    book = Book.find(params[:id])
    book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :pages, :authors)
  end
end
