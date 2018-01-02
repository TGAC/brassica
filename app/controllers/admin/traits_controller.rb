class Admin::TraitsController < Admin::BaseController
  def index
    @traits = Trait.all
  end

  def new
    @trait = Trait.new(canonical: false)
  end

  def edit
    @trait = Trait.find(params[:id])
  end

  def create
    @trait = Trait.new(trait_params)

    if @trait.save
      redirect_to admin_traits_path, notice: "Trait '#{@trait.name}' created"
    else
      render :new
    end
  end

  def update
    @trait = Trait.find(params[:id])

    if @trait.update(trait_params)
      redirect_to admin_traits_path, notice: "Trait '#{@trait.name}' updated"
    else
      render :edit
    end
  end

  private

  def trait_params
    params.require(:trait).permit(:name, :label, :description, :canonical, :data_provenance)
  end
end
