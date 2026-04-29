# frozen_string_literal: true

class Todo < ApplicationRecord
  include Completable

  attr_accessor :completed

  belongs_to :todo_list, required: true, inverse_of: :todos

  has_one :user, through: :todo_list

  scope :overdue, -> { incomplete.where('due_at <= ?', Time.current) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }

  scope :filter_by_status, ->(params) {
    case params[:status]&.strip&.downcase
    when 'overdue' then overdue
    when 'completed' then completed
    when 'incomplete' then incomplete
    else all
    end
  }

  scope :order_by, ->(params) {
    order, sort_by = TodoOrdering.extract_sort_and_order(params)

    column_name = column_names.excluding('id').include?(sort_by) ? sort_by : 'id'

    order(column_name => order)
  }

  before_validation on: :update do
    case completed
    when 'true' then complete
    when 'false' then incomplete
    end
  end

  validates :title, presence: true
  validates :due_at, presence: true, allow_nil: true
  validates :completed_at, presence: true, allow_nil: true

  def status
    return 'completed' if completed?
    return 'overdue' if overdue?

    'incomplete'
  end

  def serialize_as_json
    as_json(except: [:completed], methods: :status)
  end
end
