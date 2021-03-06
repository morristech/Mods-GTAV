module ApplicationHelper
  def relative(time)
    if time
      time_ago_in_words(time) + " ago"
    else
      nil
    end
  end

  def exact(time)
    if time
      time.strftime("%B #{time.day.ordinalize}, %Y - %l:%M %p")
    else
      nil
    end
  end

  def short(time)
    time.strftime("%B #{time.day.ordinalize}, %Y")
  end

  def active_cat(category)
    category == params[:category] || (params[:controller] == 'home' && category == 'home') || (@submission && @submission.category == category) ? 'active_menu_item' : ''
  end

  def active_sub(subcategory)
    param = params[:subcategory]
    if param && param != 'all'
      param.humanize.titleize == subcategory ? 'active_subcategory' : ''
    elsif (!param || param == 'all') && subcategory == 'all'
      'active_subcategory'
    end
  end

  def get_request_ip
    request.headers['X-Forwarded-For'] || request.ip
  end

  def require_admin
    return redirect_to root_path unless (current_user && current_user.admin)
  end

  def is_admin?
    current_user && current_user.admin
  end
end
