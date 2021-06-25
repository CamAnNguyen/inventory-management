module ApplicationHelper
  def employee_breadcrumb(&block)
    content_tag 'ul', class: 'employees__header flex text-gray-600 py-4 text-2xl font-semibold' do
      base = content_tag 'li', nil, class: 'text-teal-700' do
        link_to t('employees.index.title'), employees_path, class: 'underline'
      end

      concat(base)

      if block_given?
        concat content_tag('li', '/', class: 'mx-2')
        concat content_tag('li', capture { block.call(self) })
      end
    end
  end

  def order_status(order)
    %w[fulfilled restocked returned fulfillable].each do |state|
      return t("order.#{state}") if order.send("#{state}?")
    end

    t('order.unfulfillable')
  end

  ORDER_STATUS_CLASS = {
    'fulfilled': 'bg-green-200 text-green-800',
    'restocked': 'bg-blue-600 text-blue-100',
    'returned': 'bg-pink-600 text-pink-100',
    'fulfillable': 'bg-yellow-200 text-yellow-800'
  }.freeze

  def order_status_class(order)
    %w[fulfilled restocked returned fulfillable].each do |state|
      return ORDER_STATUS_CLASS[state.to_sym] if order.send("#{state}?")
    end

    # unfulfillable
    'bg-red-200 text-red-800'
  end

  def line_item_fulfillable_class(order, line_item)
    if !order.fulfilled? && !order.returned?
      if line_item.fulfillable?
        'bg-green-100 text-green-800'
      else
        'bg-red-100 text-red-800'
      end
    end
  end

  def fulfill_order_button_class(order)
    if order.fulfillable?
      'bg-teal-600 text-white'
    else
      'bg-gray-500 text-gray-300 cursor-not-allowed'
    end
  end

  def return_order_button_class(order)
    if order.fulfilled?
      'bg-pink-600 text-pink-100'
    else
      'bg-gray-500 text-gray-300 cursor-not-allowed'
    end
  end

  def restock_order_button_class(order)
    if order.returned?
      'bg-teal-600 text-white'
    else
      'bg-gray-500 text-gray-300 cursor-not-allowed'
    end
  end

  def fix_address_button_class(fixable)
    if fixable
      'bg-purple-500 hover:bg-purple-400 text-white '
    else
      'bg-gray-500 text-gray-300 cursor-not-allowed'
    end
  end
end
