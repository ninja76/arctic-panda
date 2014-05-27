  def getname(ngc, names)
    names.each_line do |l|
      m_ngc = l[36,5]
      name = l[0,35]
      if ngc == m_ngc
        return name
      end
    end
    return "-"
  end

  def transCon(con)
    uri = open("datasets/const.csv"){ |f| f.read }
    uri.each_line do |l|
      data = l.split("\t")
      if con == data[0]
        return data[1]
      end
    end
    return con
  end

  def transtype(type)
    case type
    when "Gxy"
      return "Galaxy"
    when "GxyCld"
      return "Galaxy Cloud"
    when "MWSC"
      return "Milky Way Star Cloud"
    when "HllRgn"
      return "Hll Region"
    when "SNR"
      return "Supernova Remnant"
    when "Neb"
      return "Nebula"
    when "OC"
      return "Open star cluster"
    when "PN"
      return "Planerary nebula"
    when "GC"
      return "Globular star cluster"
    when "DS"
      return "Double star"
    when "C+N"
      return "Cluster associated with nebulosity"
    when "OC+Neb"
      return "Open Cluster associated with nebulosity"
    when "Ast"
      return "Asterism"
    when "?"
      return "Unknown type"
    else
      return "Unknown type"
    end
  end
