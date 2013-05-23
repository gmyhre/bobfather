module ApplicationHelper

  def bobfather_selection_options(user)
    user.friends.sort_by{|x| x.name}.collect{|x| [x.id, image_tag(x.fb_image_url) + x.name]}
  end

  def bootstrap_class_for flash_type
     case flash_type
       when :success
         "alert-success"
       when :error
         "alert-error"
       when :alert
         "alert-block"
       when :notice
         "alert-info"
       else
         flash_type.to_s
     end
   end

end
