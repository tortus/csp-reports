class Domain

  def self.all
    sql = 'select domain, count(*) from reports group by domain'
    records = DataMapper.repository.adapter.select(sql)
  end

end
