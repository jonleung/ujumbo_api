class Api::PipelinesController < ApiController

  before_filter :current_user, only: [:create]

  def create
    render_error "user_id and product_id params required!" if !:user_id.in?(params.keys) || !:product_id.in?(params.keys)

    @product = Product.find(params[:product_id])
    @pipelines = @product.pipelines.new
    @pipeline.name = params[:pipeline][:name]

    params[:pipes].each do |pipe_hash|
      render_error "There should only be 1 key here, the pipe type, right now there are both #{pipe.keys}" if pipe.keys.size > 1
      pipe_hash.recursive_symbolize_keys!

      previous_pipe = nil

      pipe_hash.each do |pipe_type, pipe_properties_params|
        pipe_class = pipe_type.camelize.constantize
        if previous_pipe.present?
          pipe_properties_params.merge!(previous_pipe_id: previous_pipe.id)
        end
        pipe = pipe_class.new(pipe_properties_params)
        pipe.pipeline = @pipeline

        previous_pipe = pipe

      end
      
    end
    
    render json: true
  end

end
