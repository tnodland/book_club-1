class BooksController < ApplicationController
  def index
    @books = sort_params
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
    @error = "error"
    @book = Book.create(book_params)
    @book.title = @book.title.titleize
    authors = author_params[:authors].split(", ")


    if @book.save
      if authors.length == 0
        @book.destroy
        redirect_to new_book_path
        flash[:failure] = "A book needs at least one author"
      else
        authors.each do |author|
          book_author = Author.find_or_create_by(name: author.titleize)
          AuthorBook.create(author: book_author, book: @book)
        end
        redirect_to book_path(@book)
      end
    else
      render 'books/new'
    end
  end

  def delete
    book = Book.find(params[:id])
    book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :pages, :pub_date)
  end

  def author_params
    params.require(:book).permit(:authors)
  end

  def sort_params
    if params[:sort] == "pages"
      Book.sort_by_pages(params[:order].to_sym)
    elsif params[:sort] == "pub_date"
      Book.sort_by_pub_date(params[:order].to_sym)
    elsif params[:sort] == "reviews"
      Book.sort_by_num_reviews(params[:order].upcase)
    else
      Book.all
    end
  end
end
