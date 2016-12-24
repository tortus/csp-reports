class Domain

  def self.all
    sql = 'SELECT domain, SUM(count) AS count FROM reports GROUP BY domain ORDER BY count DESC'
    records = DataMapper.repository.adapter.select(sql)
  end

end
