class Hash
  
  def flatten
    inject({}) do |result,(k,v)|
      if v.is_a?(Hash)
        result.update v.flatten
      else
        result[k] = v
      end
      result
    end
  end
  
  def flatten!
    replace flatten
  end
  
end