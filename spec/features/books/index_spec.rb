require 'rails_helper'

RSpec.describe 'book index page', type: :feature do
  before :each do
    @book_4 = create(:book, pages: 600, pub_date: 2000)
    @book_2 = create(:book, pub_date: 1950)
    @book_1 = create(:short_book, pub_date: 1900)
    @book_3 = create(:long_book, pub_date: 1975)
    @author_1 = create(:author)
    @author_2 = create(:author)

    AuthorBook.create(author: @author_1, book: @book_1)
    AuthorBook.create(author: @author_2, book: @book_2)

    @review_1 = create(:good_review, book: @book_1, user_name: "User 1")
    @review_8 = create(:good_review, book: @book_1, user_name: "User 1")
    @review_9 = create(:good_review, book: @book_1, user_name: "User 1")
    @review_2 = create(:good_review, book: @book_1, user_name: "User 2")
    @review_3 = create(:review, book: @book_2, user_name: "User 3")
    @review_4 = create(:review, book: @book_2, user_name: "User 1")
    @review_10 = create(:review, book: @book_2, user_name: "User 1")
    @review_5 = create(:review, book: @book_3, user_name: "User 2")
    @review_6 = create(:bad_review, book: @book_3, user_name: "User 3")
    @review_7 = create(:bad_review, book: @book_4, user_name: "User 4")
  end

  it 'shows all books contents' do
    visit books_path

    within "#book-#{@book_1.id}" do
      expect(page).to have_css("img[src*='#{@book_1.book_cover_photo}']")
      expect(page).to have_content(@book_1.title)
      expect(page).to have_content("Pages: #{@book_1.pages}")
      expect(page).to have_content("Publication Year: #{@book_1.pub_date}")
      expect(page).to have_content("Author(s): #{@book_1.authors.name}")
    end

    within "#book-#{@book_2.id}" do
      expect(page).to have_css("img[src*='#{@book_2.book_cover_photo}']")
      expect(page).to have_content(@book_2.title)
      expect(page).to have_content("Pages: #{@book_2.pages}")
      expect(page).to have_content("Publication Year: #{@book_2.pub_date}")
      expect(page).to have_content("Author(s): #{@book_2.authors.name}")
    end
  end

  it 'shows average book rating' do
    visit books_path

    within "#book-#{@book_1.id}" do
      expect(page).to have_content("Average Rating: #{@book_1.average_rating}")
    end
  end

  it 'shows total number of reviews' do
    visit books_path

    within "#book-#{@book_1.id}" do
      expect(page).to have_content("Total No. of Reviews: #{@book_1.total_reviews}")
    end
  end

  it 'shows statistics about all books' do
    visit books_path

    within "#book_stats" do

      within "#best_three" do
        expect(page).to have_content("Highest-Rated Books:")
        expect(page).to have_link("#{@book_1.title}")
        expect(page).to have_link("#{@book_2.title}")
        expect(page).to have_link("#{@book_3.title}")
      end

      within "#worst_three" do
        expect(page).to have_content("Worst-Rated Books:")
        expect(page).to have_link("#{@book_4.title}")
        expect(page).to have_link("#{@book_3.title}")
        expect(page).to have_link("#{@book_2.title}")
      end

      within "#most_reviews" do
        expect(page).to have_content("Users With The Most Reviews:")
        expect(page).to have_content("#{@review_1.user_name} has written #{Review.reviews_by_name("User 1")} reviews")
        expect(page).to have_content("#{@review_2.user_name} has written #{Review.reviews_by_name("User 2")} reviews")
        expect(page).to have_content("#{@review_3.user_name} has written #{Review.reviews_by_name("User 3")} reviews")
      end
    end
  end

  it "can sort books by pages" do
    visit books_path

    within "#dropdown" do
      click_link "Page Count: Low to High"
    end

    expect(current_path).to eq(books_sort_path("pages", :asc))

    within "#books" do
      expect(page.all(".book")[0]).to have_content(@book_1.title)
      expect(page.all(".book")[1]).to have_content(@book_2.title)
      expect(page.all(".book")[2]).to have_content(@book_3.title)
      expect(page.all(".book")[3]).to have_content(@book_4.title)
    end

    within "#dropdown" do
      click_link "Page Count: High to Low"
    end

    expect(current_path).to eq(books_sort_path("pages", :desc))

    within "#books" do
      expect(page.all(".book")[0]).to have_content(@book_4.title)
      expect(page.all(".book")[1]).to have_content(@book_3.title)
      expect(page.all(".book")[2]).to have_content(@book_2.title)
      expect(page.all(".book")[3]).to have_content(@book_1.title)
    end
  end

  it "can sort books by pub date" do
    visit books_path

    within "#dropdown" do
      click_link "Publication Date: Oldest to Newest"
    end

    expect(current_path).to eq(books_sort_path("pub_date", :asc))

    within "#books" do
      expect(page.all(".book")[0]).to have_content(@book_1.title)
      expect(page.all(".book")[1]).to have_content(@book_2.title)
      expect(page.all(".book")[2]).to have_content(@book_3.title)
      expect(page.all(".book")[3]).to have_content(@book_4.title)
    end

    within "#dropdown" do
      click_link "Publication Date: Newest to Oldest"
    end

    expect(current_path).to eq(books_sort_path("pub_date", :desc))

    within "#books" do
      expect(page.all(".book")[0]).to have_content(@book_4.title)
      expect(page.all(".book")[1]).to have_content(@book_3.title)
      expect(page.all(".book")[2]).to have_content(@book_2.title)
      expect(page.all(".book")[3]).to have_content(@book_1.title)
    end
  end

  it "can sort books by number of ratings" do
    visit books_path

    within "#dropdown" do
      click_link "Most Reviewed"
    end

    expect(current_path).to eq(books_sort_path("reviews", :desc))

    within "#books" do
      expect(page.all(".book")[0]).to have_content(@book_1.title)
      expect(page.all(".book")[1]).to have_content(@book_2.title)
      expect(page.all(".book")[2]).to have_content(@book_3.title)
      expect(page.all(".book")[3]).to have_content(@book_4.title)
    end

    within "#dropdown" do
      click_link "Least Reviewed"
    end

    expect(current_path).to eq(books_sort_path("reviews", :asc))

    within "#books" do
      expect(page.all(".book")[0]).to have_content(@book_4.title)
      expect(page.all(".book")[1]).to have_content(@book_3.title)
      expect(page.all(".book")[2]).to have_content(@book_2.title)
      expect(page.all(".book")[3]).to have_content(@book_1.title)
    end
  end
end
